defmodule AwesomeList.Scheduler do
    use GenServer

    alias AwesomeList.DataFetcher

    def start_link(_) do
        GenServer.start_link(__MODULE__, nil)
    end

    def init(_) do
        schedule_initial_data_fetch()
        {:ok, nil}
    end

    def handle_info(:perform, state) do
        DataFetcher.gather_data()
        schedule_next_data_fetch()
        {:noreply, state}
    end


    def schedule_initial_data_fetch() do
        Process.send_after(self(), :perform, 1000)
    end

    def schedule_next_data_fetch() do
        Process.send_after(self(), :perform, 1000 * 60 * 60 * 24)
    end
end