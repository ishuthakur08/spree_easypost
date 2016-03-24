Spree::Api::ShipmentsController.class_eval do
  def ship
    begin 
      unless @shipment.shipped?
        @shipment.ship!
      end
      respond_with(@shipment, default_template: :show)
    rescue Exception => e
      flash[:error] = e.message
      render 'spree/api/errors/shipment_error', status: 422 and return
    end
  end

  def easy_label
     @shipment = find_and_update_shipment
    begin 
      @ep_shipment = @shipment.easypost_shipment
      @ep_postage_label = @ep_shipment.postage_label 
        render :json => {url: @ep_postage_label.label_url, :success => true}, status: 200 
    rescue Exception => e
      flash[:error] = e.message
      render 'spree/api/errors/shipment_error', status: 422 and return
    end
  end

  def easy_barcode
     @shipment = find_and_update_shipment
    begin 
      @ep_shipment = @shipment.easypost_shipment
      @ep_postage_barcode = @ep_shipment.barcode 
        render :json => {url: @ep_postage_barcode, :success => true}, status: 200 
    rescue Exception => e
      flash[:error] = e.message
      render 'spree/api/errors/shipment_error', status: 422 and return
    end
  end

end
