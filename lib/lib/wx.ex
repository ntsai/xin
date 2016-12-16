
defmodule Xin.Wx do
  @moduledoc """
    #config mix add 
    def application do
      [applications: [:wechat]]
    end
    
    #config 
    config :xin, Wechat,
      appid: "wechat app id",
      secret: "wechat app secret",
      token: "wechat token",
      encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG" # 只有"兼容模式"和"安全模式"才需要配置这个值

    #wechat_controller.ex
    defmodule Proj.WechatController do
      use Xin.Wx, Proj.Web
      plug Wechat.Plugs.CheckMsgSignature when action in [:create]
    end

    #router.ex
      import Xin.Wx
      wechat_route(Proj, WechatController)
    """
    def config() do
      Wechat.config
    end

    defmacro __using__(mod) do
      quote do
        use unquote(mod), :controller

        plug Wechat.Plugs.CheckUrlSignature
        #plug Wechat.Plugs.CheckMsgSignature when action in [:create]

        def index(conn, %{"echostr" => echostr}) do
          text conn, echostr
        end

        def create(conn, _params) do
          msg = conn.assigns[:msg]
          msgtype = msg[:msgtype]
          xml = if msgtype == "text" do
            reply = build_text_reply(msg, msg.content)
            "
              <xml>
                <MsgType><![CDATA[text]]></MsgType>
                <Content><![CDATA[#{reply.content}]]></Content>
                <ToUserName><![CDATA[#{reply.to}]]></ToUserName>
                <FromUserName><![CDATA[#{reply.from}]]></FromUserName>
                <CreateTime>%{ DateTime.to_unix(DateTime.utc_now)}</CreateTime>
              </xml>
            "
          else
            ""
          end
          text conn, xml
        end

        defp build_text_reply(%{tousername: to, fromusername: from}, content) do
          %{from: to, to: from, content: content}
        end

        defoverridable [index: 2, create: 2, build_text_reply: 2] 
      end
    end

    defmacro wechat_route(app, mod) do
      quote do
        scope "/wechat", unquote(app) do
          pipe_through :api
          get "/", unquote(mod), :index
          post "/", unquote(mod), :create
        end
      end
    end

    @doc """
    获取微信用户信息，网页授权 type: 默认snsapi_base, url: 获取信息后跳转的连接, state: 额外参数,默认STATE
    """
    def snsapi_url(url), do: snsapi_url(url, "snsapi_base", "STATE")
    def snsapi_url(url, type, state) do
      "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{config[:appid]}&redirect_uri=#{URI.encode_www_form(url)}&response_type=code&scope=#{type}&state=#{state}#wechat_redirect"
    end

    @doc """
    获取用户 access_token (openid)
    """
    def access_token(code) do
      url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{config[:appid]}&secret=#{config[:secret]}&code=#{code}&grant_type=authorization_code"
      data = HTTPoison.get!(url)
      Poison.decode!(data.body, keys: :atoms)
    end

end


defmodule Xin.Wx.Plug.CheckOpenid do
  @moduledoc """
  Plug to check opneid. Openid 检查插件
  """  
  import Plug.Conn
  use Phoenix.Controller
  use Phoenix.Router

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    has_openid?(conn)
  end

  defp has_openid?(conn) do
      openid = get_session(conn, :openid)
      if openid do
        conn
      else
        get_openid(conn)
      end
  end

  defp get_openid(conn) do
    if conn.params["code"] do
      token = Xin.Wx.access_token(conn.params["code"])
      conn |> put_session(:openid, token[:openid]) 
    else
      redirect halt(conn), external: Xin.Wx.snsapi_url(get_url_path(conn))
    end
  end

  defp get_url_path(conn) do
    host = Xin.Http.headers(conn)[:host]
    path = conn.request_path
    params_url = URI.encode_query(conn.params)
    "http://#{host}#{path}?#{params_url}"
  end
end