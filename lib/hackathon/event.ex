defmodule Hackathon.Event do
  require Record
  Record.defrecord(:event,
                    start: DateTime.new!(~D[2025-02-24], ~T[15:00:00.000], "Europe/Stockholm"),
                    end: DateTime.new!(~D[2025-02-24], ~T[16:00:00.000], "Europe/Stockholm"))
end
