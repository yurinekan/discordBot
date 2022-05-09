defmodule Jacquin.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  def advice_host, do: "https://api.adviceslip.com/advice"
  def chess_host, do: "https://api.chess.com/pub/"
  def coffee_host, do: "https://coffee.alexflipnote.dev/random"
  def meals_host, do: "https://www.themealdb.com/api/json/v1/1/"
  def drinks_host, do: "https://www.thecocktaildb.com/api/json/v1/1/"
  def brasil_host, do: "https://brasilapi.com.br/api/cep/v1/"
  def disify_host, do: "https://www.disify.com/api/email/"
  def btc_host, do: "https://www.mercadobitcoin.net/api/btc/ticker"
  def isEven_host, do: "https://api.isevenapi.xyz/api/iseven/"
  def covid_host, do: "https://api.covid19api.com/summary"

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  # Capturar e identificar comandos
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    if String.starts_with?(msg.content, "!") do
      cond do
        msg.content == "!oi" ->
          send_msg("olá #{msg.author.username}! 😁", msg)

        msg.content == "!btc" ->
          check_btc_price(msg)

        msg.content == "!receita" ->
          random_dish(msg)

        msg.content == "!drink" ->
          random_drink(msg)

        msg.content == "!café" ->
          send_msg("#{coffee_host()}", msg)

        msg.content == "!chess" ->
          top_daily_player(msg)

        msg.content == "!conselho" ->
          generate_advice(msg)

        msg.content == "!covid" ->
          covid_data(msg)

        String.starts_with?(msg.content, "!par ") ->
          is_even(msg, paramaters(msg.content))

        String.starts_with?(msg.content, "!cep ") ->
          check_cep(msg, msg.content)

        String.starts_with?(msg.content, "!email ") ->
          check_email(msg, msg.content)

        true ->
          send_msg("não consegui identificar o comando 😰", msg)
      end
    end
  end

  def handle_event(_event) do
    :ignore
  end

  def covid_data(msg) do
    resp = HTTPoison.get!("#{covid_host()}")
    map = Poison.decode!(resp.body)

    send_msg("já são #{map["Global"]["TotalConfirmed"]} casos de Covid-19 ao redor do mundo 🌎", msg)
  end

  def is_even(msg, number) do
    resp = HTTPoison.get!("#{isEven_host()}#{number}")
    map = Poison.decode!(resp.body)

    if map["iseven"] do
      send_msg("#{number} é par!", msg)
    end

    if map["iseven"] == false do
      send_msg("#{number} é ímpar!", msg)
    end
  end

  def generate_advice(msg) do
    resp = HTTPoison.get!("#{advice_host()}")
    map = Poison.decode!(resp.body)

    send_msg("#{map["slip"]["advice"]}", msg)
  end

  def top_daily_player(msg) do
    resp = HTTPoison.get!("#{chess_host()}leaderboards")
    map = Poison.decode!(resp.body)

    daily_rank = map["daily"]
    top_player = Enum.at(daily_rank, 0)["username"]
    image = Enum.at(daily_rank, 0)["avatar"]

    send_msg("#{image}", msg)
    send_msg("#{top_player} é o top 1 player de chess.com do dia!", msg)
  end

  def random_dish(msg) do
    resp = HTTPoison.get!("#{meals_host()}random.php")
    map = Poison.decode!(resp.body)

    meals = map["meals"]

    dish = Enum.at(meals, 0)["strMeal"]
    recipe = Enum.at(meals, 0)["strInstructions"]
    yt = Enum.at(meals, 0)["strYoutube"]

    send_msg(
      "
    que tal #{dish}? 🤤
    #{recipe}
    este é o vídeo para a receita: #{yt}",
      msg
    )
  end

  def random_drink(msg) do
    resp = HTTPoison.get!("#{drinks_host()}random.php")
    map = Poison.decode!(resp.body)

    drinks = map["drinks"]

    drink = Enum.at(drinks, 0)["strDrink"]
    recipe = Enum.at(drinks, 0)["strInstructions"]
    image = Enum.at(drinks, 0)["strDrinkThumb"]
    alcohol = Enum.at(drinks, 0)["strAlcoholic"]

    send_msg("#{image}", msg)

    send_msg(
      "
    que tal #{drink}? 🤤
    #{recipe}
    esse drink é #{alcohol}",
      msg
    )
  end

  def check_cep(msg, cep) do
    resp = HTTPoison.get!("#{brasil_host()}#{cep}")
    map = Poison.decode!(resp.body)
    IO.puts("#{brasil_host()}#{cep}")

    send_msg(
      "sei que você mora em #{map["city"]}, no bairro #{map["neighborhood"]} em #{map["street"]} 👀",
      msg
    )
  end

  def check_email(msg, email) do
    resp = HTTPoison.get!("#{disify_host()}#{email}")
    map = Poison.decode!(resp.body)

    disposable = map["disposable"]
    dns = map["dns"]

    case dns do
      true -> send_msg("esse e-mail tem o domínio verdadeiro", msg)
      false -> send_msg("esse e-mail tem o domínio falso", msg)
      _ -> :ignore
    end

    case disposable do
      true -> send_msg("e provavelmente é descartável", msg)
      false -> send_msg("e não deve descartável", msg)
      _ -> :ignore
    end
  end

  def check_btc_price(msg) do
    resp = HTTPoison.get!("#{btc_host()}")
    map = Poison.decode!(resp.body)

    last = map["ticker"]["last"]

    send_msg("o preço do bitcoin está #{last} reais", msg)
  end

  def paramaters(content) do
    [_head | tail] = String.split(content)
    tail
  end

  def send_msg(content, msg) do
    Api.create_message(msg.channel_id, content)
  end
end
