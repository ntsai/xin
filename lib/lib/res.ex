defmodule IndexView do
  def fnquote do
    quote do
      def index(conn, params) do
        c = get_c(conn, params, :index)
        list(c)
      end

      def list(c) do
        if c[:model] do
          c |> list_base |> list_run
        else
          response c
        end
      end

      def list_run(c) do
        c
        |> list_query
        |> list_paginator
        |> list_preload
        |> list_make
        |> list_select
        |> list_model
        |> response
      end

      def list_base(c) do
        unless Map.has_key?(c,:qs) do
          qs = from m in c.model
          c = Map.put c, :qs, qs
        end        
        c
      end

      def list_query(c) do
        model_keys = for x <- Map.keys(c.form), do: Atom.to_string(x)
        pass_query = for x <- Map.keys(c.params) do
          pwd = nil
          unless x in model_keys, do: pwd = x
          if String.contains?(x, "__"), do: pwd = nil
          pwd
        end

        pass_query = List.delete pass_query, nil   

        if Map.size(c.params) > 0,  do: c = Map.put c, :qs, QueryParam.query_param(c.qs, c.params, pass_query, c[:col_type])
        if c[:where],  do: c = Map.put c, :qs, QueryParam.query_param(c.qs, c.where, pass_query, c[:col_type])
        c
      end

      def list_paginator(c) do
        page_size = 20
        page = 1
        page_up = nil
        page_next = nil
        if c[:page_size],  do: page_size = c.page_size
        page_count_query = select(c.qs,[d],count(d.id))
        page_total = Repo.one(page_count_query)
        qs = limit(c.qs, ^page_size)
        if c[:order_by], do: qs = order_by(qs, [d], ^c.order_by)

        if c.params["page"] do
          num = String.to_integer c.params["page"]
          o = (num-1) * page_size
          qs = offset(qs, ^o)
        end

        if c.params["page"], do: page = String.to_integer c.params["page"]
        page_count =  div(page_total,page_size)
        if page > 1, do: page_up = page-1
        if page_total > page_size*page, do: page_next = page+1
        if page_total/page_size > page_count, do: page_count = page_count + 1
        up_url = nil
        next_url = nil
        if page_up, do: up_url = c.conn.request_path <> "?" <> URI.encode_query(Map.put c.params, "page", page_up)
        if page_next, do: next_url = c.conn.request_path <> "?" <> URI.encode_query(Map.put c.params, "page", page_next)

        c = c |> Map.put(:json, c.json |> Map.put(:page,
            %{size: page_size, up: up_url, next: next_url, total: page_total, pages: page_count, now: page}))
        Map.put c, :qs, qs
      end

      def list_preload(c) do
        if c[:preload] do
          qs = preload(c.qs, ^c[:preload])  
          c = Map.put c, :qs, qs
        end
        c
      end

      def list_make(c) do
        c = Map.put c, :data, Repo.all(c.qs)
        # data = Repo.all(c.qs)
        # if c[:preload] do
        #   data = Repo.preload data, c[:preload]
        # end
        # c = Map.put c, :data, data
        # c
      end

      def list_model(c) do
        c
      end


      def format_fk(data, take) do
        fk = Enum.filter(take, fn(x) -> String.contains?(Atom.to_string(x),"__") end)    

        if fk != [] do
          take = take ++ fk
          new_data = for d <- fk do
            [a,b] = String.split(Atom.to_string(d),"__")
            v = Map.get(data, String.to_atom(a))
            if v, do: v = Map.get(v, String.to_atom(b))
            {d, v}
          end 
          new_data = Enum.into new_data,%{}
          data = Map.merge data, new_data
        end

        Map.take data,take
      end

      def format_data(c, data, take) do
        if c[:preload] do
          format_fk(data,take)
        else
          Map.take data, take
        end       
      end


      def list_select(c) do
        if c[:select] do
          take = c.select ++ [:id]
          if c[:exclude] , do: take = take -- c[:exclude]
          c = Map.put(c, :data, Enum.map(c.data, fn(d) -> format_data(c, d, take) end))
        else
          if c[:exclude] do
            c = Map.put(c, :data, Enum.map(c.data, fn(d) -> Map.drop d, c.exclude end))
          end
        end
        c
      end

      defoverridable [
        index: 2, list: 1, list_run: 1, list_base: 1, list_query: 1,
        list_model: 1, list_make: 1, list_select: 1,
      ]
    end
  end
end

defmodule CreateView do
  def fnquote do
    quote do
      def create(conn, params) do
        c = get_c(conn, params, :create) |> valid_forms
        if c.code == 200 do
          post(c)
        else
          response c
        end
      end

      def post(c) do
        if c[:model] do
          c |> create_run
        else
          response c
        end
      end

      def create_run(c) do
        c |> create_model |> response
      end

      def create_model(c) do
         Repo.insert!(c.changeset)
         c
      end

      defoverridable [create: 2, post: 1, create_run: 1, create_model: 1, ]
    end
  end
end

defmodule UpdateView do
  def fnquote do
    quote do
      def update(conn, params) do
        c = get_c(conn, params, :update) |> valid_forms
        if c.code == 200 do
          put(c)
        else
          response c
        end
      end

      def put(c) do
        if c[:model] do
          c |> update_run
        else
          response c
        end
      end

      def update_run(c) do
        c |> update_model |> response
      end

      def update_model(c) do
         model = Repo.get!(c.model, String.to_integer(c.params["id"]))
         changeset = c.model.changeset(model, c.params)
         Repo.update!(changeset)
         c
      end

      defoverridable [update: 2, put: 1, update_run: 1, update_model: 1, ]
    end
  end
end

defmodule DetailView do
  def fnquote do
    quote do
      def show(conn, params) do
        c = get_c(conn, params, :detail)
        if c.params["id"] do
          get(c)
        else
          c |> Map.put(:code,401) |> add_data(:errors, "params has not Id") |> response
        end
      end

      def get(c) do
        if c[:model] do
          c |> get_run
        else
          response c
        end
      end

      def get_run(c) do
        c |> get_model |> get_select |> response
      end

      def get_model(c) do
         model = Repo.get!(c.model, String.to_integer(c.params["id"]))
         c |> Map.put(:data, model)
      end

      def get_select(c) do
        detail_select = c[:detail_select] || c[:select] || nil
        detail_exclude = c[:detail_exclude] || c[:exclude] || nil
        if detail_select do
          take = detail_select ++ [:id]
          if c[:exclude] , do: take = take -- detail_exclude
          c = Map.put(c, :data, Map.take(c.data,take))
        else
          if detail_exclude do
            c = Map.put(c, :data, Map.take(c.drop, detail_exclude))
          end
        end
        c
      end

      defoverridable [show: 2, get: 1, get_run: 1, get_model: 1, ]
    end
  end
end

defmodule DeleteView do
  def fnquote do
    quote do
      def delete(conn, params) do
        c = get_c(conn, params, :delete)
        if c.params["id"] do
          del(c)
        else
          c |> Map.put(:code,401) |> add_data(:errors, "params has not Id") |> response
        end
      end

      def del(c) do
        if c[:model] do
          c |> delete_run
        else
          response c
        end
      end

      def delete_run(c) do
        c |> delete_model |> response
      end

      def delete_model(c) do
        model = Repo.get!(c.model, String.to_integer(c.params["id"]))
        Repo.delete!(model)
        c
      end
      defoverridable [delete: 2, del: 1, delete_run: 1, delete_model: 1, ]
    end
  end
end

defmodule Xin.Lib.Resource do
  use Phoenix.Router

  @doc """
  这是资源配置宏:

  """
  def add_data(c,key,data), do: c |> Map.put(:json, Map.put(c.json, key ,data))
  def drop_data(c,key), do: c |> Map.put(:json, Map.drop(c.json, [key]))

  defmacro resful(path, mod) do
    quote do
      get unquote(path), unquote(mod), :index
      get unquote(path)  <> "/detail/:id", unquote(mod), :show
      post unquote(path) <> "/update", unquote(mod), :update
      post unquote(path) <> "/create", unquote(mod), :create
      post unquote(path) <> "/delete", unquote(mod), :delete
    end
  end

  defmacro conf(repo, do: ini) do
    quote do
      import Resource
      import Ecto.Query
      import Ecto.Changeset
      import QueryParam
      alias unquote(repo)
      c = unquote(ini)

      Module.put_attribute __MODULE__, :config, c

      if c[:method] do
        if String.contains?(c.method, "l"),  do: unquote IndexView.fnquote
        if String.contains?(c.method, "c"),  do: unquote CreateView.fnquote
        if String.contains?(c.method, "u"),  do: unquote UpdateView.fnquote
        if String.contains?(c.method, "r"),  do: unquote DetailView.fnquote
        if String.contains?(c.method, "d"),  do: unquote DeleteView.fnquote
      else
        unquote IndexView.fnquote
        unquote CreateView.fnquote
        unquote UpdateView.fnquote
        unquote DetailView.fnquote
        unquote DeleteView.fnquote
      end

      def get_c(conn, params, action) do
        @config
        |> Map.put(:conn, conn)
        |> Map.put(:params, params)
        |> Map.put(:action, action)
        |> Map.put(:code, 200)
        |> Map.put(:data, %{})
        |> Map.put(:msg, "")
        |> Map.put(:json, %{})
      end

      def response(c) do
        res_data = %{code: c.code, data: c.data, msg: c.msg}
        if Map.size(c.json) > 0 do
          res_data = Map.merge res_data, c.json
        end
        json c.conn, res_data
      end

      def valid_forms(c, valid_rule \\ nil) do
        changeset = %{}
        if c.action == :create and c[:create_form], do: valid_rule = c.create_form
        if c.action == :update and c[:update_form], do: valid_rule = c.update_form

        if c[:model] do
          # model valid
          if valid_rule, do: changeset = cast(c.form, c.params, valid_rule[:req], valid_rule[:opt])
          unless valid_rule, do: changeset = c.model.changeset(c.form, c.params)
        else
          # not model valid
          if valid_rule do
            errors = Enum.reduce(valid_rule[:req], [], fn(k,e) ->
              unless Map.has_key?(c.params,k) do
                 Dict.put(e, String.to_atom(k), "can't be blank")
              else
                e
              end
            end)
            if Dict.size(errors) > 0, do: changeset = %{errors: errors}
          end
        end

        c = Map.put c, :changeset, changeset

        if Map.has_key?(changeset, :errors) and Dict.size(changeset.errors) > 0 do
            errors = Enum.into(changeset.errors, %{})
            c = c |> Map.put(:code, 401) |> add_data(:errors, errors)
        end
        c
      end

      defoverridable [get_c: 3, response: 1,valid_forms: 2]
    end
  end

  defmacro __using__(m) do
    quote do
      use unquote(m), :controller
      import Resource
      import Ecto.Query
      import Ecto.Changeset
      import QueryParam
    end
  end

end

defmodule QueryParam do
  import Ecto.Query

  @pass_query  ["page","offset","limit"]
  
  def make_value(type, key, value) do
    if type do
      if String.contains?(key,"__"), do: [key,_] = String.split(key,"__")
      
      if type[String.to_atom(key)] do

        case type[String.to_atom(key)] do
          :time ->
            value = Ecto.Time.cast! value
          :date ->
            #处理不正确的日期字符
            [y, m, d] = String.split(value, "-")
            if String.length(m) == 1, do: m = "0" <> m
            if String.length(d) == 1, do: d = "0" <> d
            value = Ecto.Date.cast!("#{y}-#{m}-#{d}")
          :datetime ->
            #处理不正确的日期字符
            [y, m, d] = String.split(value, "-")
            if String.length(m) == 1, do: m = "0" <> m
            if String.length(d) == 1, do: d = "0" <> d            
            value = Ecto.DateTime.cast!("#{y}-#{m}-#{d} 00:00:00")
          _ ->
            value = value
        end
      end
    end
    value
  end

  def query_param(qs,params, pwd \\ nil, type \\ []) do
    unless pwd, do: pwd = @pass_query, else: pwd = @pass_query ++ pwd
    q = Enum.reduce params, qs , fn({a, b}, q) ->
      new_value = make_value(type, a, b)
      query_list(q, col_string(a), new_value, pwd)
    end
    q
  end


  def col_string(key) do
    if is_atom(key) do
      key = Atom.to_string(key)
    end
    key
  end

  def query_list(qs, s, b, pwd) do
    cond do
      s in pwd ->
        qs
      String.contains? s,"__" ->
        [col_string, w] = String.split(s,"__")
        col = String.to_atom col_string
        case w do
          "gt" ->
            qs = where(qs, [c], field(c, ^col) > ^b)

          "gte" ->
            qs = where(qs, [c], field(c, ^col) >= ^b)

          "lt" ->
            qs = where(qs, [c], field(c, ^col) < ^b)

          "lte" ->
            qs = where(qs, [c], field(c, ^col) <= ^b)

          "like" ->
            v = "%#{b}%"
            qs = where(qs, [c], like(field(c, ^col),^v))

          "in" ->
            v = String.split b,","
            qs = where(qs, [c], field(c, ^col) in ^v)

          "startswith" ->
            v = "#{b}%"
            qs = where(qs, [c], like(field(c, ^col),^v))

          "endswith" ->
            v = "%#{b}"
            qs = where(qs, [c], like(field(c, ^col),^v))

          "isnil" ->
            qs = where(qs, [c], is_nil(field(c, ^col)))

          _ ->
            IO.puts "not seach filter word."
        end
      true ->
        qs = where(qs, [c], field(c, ^String.to_atom(s)) == ^b)
    end
  end
end

defimpl Poison.Encoder, for: Any do
  def encode(%{__struct__: _} = struct, options) do
    map = struct
          |> Map.from_struct
          |> sanitize_map
    Poison.Encoder.Map.encode(map, options)
  end

  defp sanitize_map(map) do
    Map.drop(map, [:__meta__, :__struct__])
  end
end
