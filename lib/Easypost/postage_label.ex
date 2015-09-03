defmodule Easypost.PostageLabel do

  defstruct [
    id: "",
    object: "PostageLabel",
    created_at: "",
    updated_at: "",
    date_advance: 0,
    integrated_form: "none",
    label_date: "",
    label_resolution: 300,
    label_size: "",
    label_type: "default",
    label_file_type: "",
    label_url: "",
    label_pdf_url: "",
    label_epl2_url: "",
    label_zpl_url: "",
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    created_at: String.t,
    updated_at: String.t,
    date_advance: number,
    integrated_form: String.t,
    label_date: String.t,
    label_resolution: number,
    label_size: String.t,
    label_type: String.t,
    label_file_type: String.t,
    label_url: String.t,
    label_pdf_url: String.t,
    label_epl2_url: String.t,
    label_zpl_url: String.t,
  }

end