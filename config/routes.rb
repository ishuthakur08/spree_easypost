Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :api, defaults: { format: 'json' } do
	  resources :shipments, only: [:create, :update] do
	      member do
	        get :easy_label
	        get :easy_barcode
	      end
	    end
  end
end
