defmodule Easypost.Client do

  defmacro __using__(config) do
    quote do
      def conf, do: unquote(config)
      def create_address(address) do
        unquote(Easypost.Client.Address).create_address(conf(), address)
      end
      def create_parcel(parcel) do
        unquote(Easypost.Client.Parcel).create_parcel(conf(), parcel)
      end
      def create_shipment(shipment) do
        unquote(Easypost.Client.Shipment).create_shipment(conf(), shipment)
      end
      def create_batch(shipments) do
        unquote(Easypost.Client.Batch).create_batch(conf(), shipments)
      end
      def create_and_buy_batch(shipments) do
        unquote(Easypost.Client.Batch).create_and_buy_batch(conf(), shipments)
      end
      def batch_labels(batch_id, label) do
        unquote(Easypost.Client.Batch).batch_labels(conf(), batch_id, label)
      end
      def add_to_batch(batch_id, shipments) do
        unquote(Easypost.Client.Batch).add_to_batch(conf(), batch_id, shipments)
      end
      def remove_from_batch(batch_id, shipments) do
        unquote(Easypost.Client.Batch).remove_from_batch(conf(), batch_id, shipments)
      end
      def insure_shipment(shipment_id, insurance) do
        unquote(Easypost.Client.Shipment).insure_shipment(conf(), shipment_id, insurance)
      end
      def buy_shipment(shipment_id, rate) do
        unquote(Easypost.Client.Shipment).buy_shipment(conf(), shipment_id, rate)
      end
      def create_customs_forms(customs_info) do
        unquote(Easypost.Client.Customs).create_customs_forms(conf(), customs_info)
      end
      def create_pickup(pickup) do
        unquote(Easypost.Client.Pickup).create_pickup(conf(), pickup)
      end
      def buy_pickup(pickup_id, pickup) do
        unquote(Easypost.Client.Pickup).buy_pickup(conf(), pickup_id, pickup)
      end
      def cancel_pickup(pickup_id) do
        unquote(Easypost.Client.Pickup).cancel_pickup(conf(), pickup_id)
      end
      def track(tracking) do
        unquote(Easypost.Client.Tracker).track(conf(), tracking)
      end
      def create_user(user) do
        unquote(Easypost.Client.User).create_user(conf(), user)
      end
      def get_child_api_keys() do
        unquote(Easypost.Client.User).get_child_api_keys(conf())
      end
      def add_carrier_account(carrier) do
        unquote(Easypost.Client.User).add_carrier_account(conf(), carrier)
      end
      def refund_usps_label(shipment_id) do
        unquote(Easypost.Client.Shipment).refund_usps_label(conf(), shipment_id)
      end
    end
  end
end

