defmodule Easypost.Client do
  @moduledoc """
  Access the Easypost API from Elixir using maps and returning structs

  ##Usage:

  First, add test key to config/test.exs and config/dev.exs like this:

      config :myapp, easypost_endpoint: "https://api.easypost.com/v2/",
                     easypost_key: "your test key"

  Then, define endpoint and key in module where you will use client:

      defmodule Myapp.Mymodule do
        use Easypost.Client, endpoint: Application.get_env(:my_app, :easypost_endpoint),                    
                           key: Application.get_env(:my_app, :easypost_key)

        #omitted...

      end

  Now, the Easypost functions will be available in the module:

      #add an address by passing a binary key map (%{"foo" => "bar"})
      create_address(user.address)

      #gets a list of rate quotes
      create_shipment(shipment)

      #purchases a shipment using a particular rate where shipment_id is the Easypost id of the shipment and rate is a map containing the Easypost rate id
      buy_shipment(shipment_id, rate)

      #creates a batch of shipments using either a list of previously created shipping ids or shipment maps
      create_batch(shipments)

  All functions return either {:ok, (struct)} or {:error, %Easypost.Error{}}, so you should pattern match the result of the functions.
  For more examples, see tests.  
  """

  defmacro __using__(config) do
    quote do
      def conf, do: unquote(config)
      def create_address(address) do
        unquote(Easypost.Address).create_address(conf(), address)
      end
      def create_parcel(parcel) do
        unquote(Easypost.Parcel).create_parcel(conf(), parcel)
      end
      def create_shipment(shipment) do
        unquote(Easypost.Shipment).create_shipment(conf(), shipment)
      end
      def create_batch(shipments) do
        unquote(Easypost.Batch).create_batch(conf(), shipments)
      end
      def create_and_buy_batch(shipments) do
        unquote(Easypost.Batch).create_and_buy_batch(conf(), shipments)
      end
      def batch_labels(batch_id, label) do
        unquote(Easypost.Batch).batch_labels(conf(), batch_id, label)
      end
      def add_to_batch(batch_id, shipments) do
        unquote(Easypost.Batch).add_to_batch(conf(), batch_id, shipments)
      end
      def remove_from_batch(batch_id, shipments) do
        unquote(Easypost.Batch).remove_from_batch(conf(), batch_id, shipments)
      end
      def insure_shipment(shipment_id, insurance) do
        unquote(Easypost.Shipment).insure_shipment(conf(), shipment_id, insurance)
      end
      def buy_shipment(shipment_id, rate) do
        unquote(Easypost.Shipment).buy_shipment(conf(), shipment_id, rate)
      end
      def create_customs_info(customs_info) do
        unquote(Easypost.CustomsInfo).create_customs_info(conf(), customs_info)
      end
      def create_pickup(pickup) do
        unquote(Easypost.Pickup).create_pickup(conf(), pickup)
      end
      def buy_pickup(pickup_id, pickup) do
        unquote(Easypost.Pickup).buy_pickup(conf(), pickup_id, pickup)
      end
      def cancel_pickup(pickup_id) do
        unquote(Easypost.Pickup).cancel_pickup(conf(), pickup_id)
      end
      def track(tracking) do
        unquote(Easypost.Tracker).track(conf(), tracking)
      end
      def create_user(user) do
        unquote(Easypost.User).create_user(conf(), user)
      end
      def get_child_api_keys() do
        unquote(Easypost.User).get_child_api_keys(conf())
      end
      def add_carrier_account(carrier) do
        unquote(Easypost.User).add_carrier_account(conf(), carrier)
      end
      def refund_usps_label(shipment_id) do
        unquote(Easypost.Shipment).refund_usps_label(conf(), shipment_id)
      end
    end
  end
end

