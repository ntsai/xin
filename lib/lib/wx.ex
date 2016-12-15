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
end