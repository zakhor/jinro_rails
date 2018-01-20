module ExtendVariantsController
  def show
    if blob = ActiveStorage::Blob.find_signed(params[:signed_blob_id])
      expires_in 120.minutes
      redirect_to ActiveStorage::Variant.new(blob, params[:variation_key]).processed.service_url(expires_in: 120.minutes, disposition: params[:disposition])
    else
      head :not_found
    end
  end
end

class ActiveStorage::VariantsController < ActionController::Base
  prepend ExtendVariantsController
end