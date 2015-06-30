defmodule EasypostTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    Easypost.start
  end
  
end