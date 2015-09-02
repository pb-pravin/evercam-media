defmodule EvercamMedia.Schedule do
  def scheduled?(schedule, timezone) do
    today_name = Timex.Date.local
    |> Timex.Date.weekday
    |> Timex.Date.day_name

    today_schedule = schedule[today_name]
    iterate(today_schedule, timezone)
  end

  defp iterate([head|tail], timezone) do
    [from, to] = String.split head, "-"
    [from_hour, from_minute] = String.split from, ":"
    [to_hour, to_minute] = String.split to, ":"

    from_date = to_date(from_hour, from_minute, timezone)
    to_date = to_date(to_hour, to_minute, timezone)
    now = Timex.Date.now

    date_format = "{ISOz}"
    {_, now_str} = Timex.DateFormat.format(now, date_format)
    {_, from_str} = Timex.DateFormat.format(from_date, date_format)
    {_, to_str} = Timex.DateFormat.format(to_date, date_format)

    from_date_now = Timex.Date.compare(from_date, now)
    now_to_date = Timex.Date.compare(now, to_date)

    case {from_date_now, now_to_date} do
      {-1, -1} ->
        true
      {0, -1} ->
        true
      {-1, 0} ->
        true
      _ ->
        iterate(tail, timezone)
    end
  end

  defp iterate(nil, timezone) do
    false
  end

  defp iterate([], timezone) do
    false
  end

  defp to_date(hours, minutes, nil) do
    to_date(hours, minutes, "UTC")
  end

  defp to_date(hours, minutes, timezone) do
    today = {Timex.Date.now.year, Timex.Date.now.month, Timex.Date.now.day}
    {h, _} = Integer.parse(hours)
    {m, _} = Integer.parse(minutes)
    time = {h, m, 0}
    Timex.Date.from({today, time}, timezone)
  end
end
