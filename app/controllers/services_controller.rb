class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, except: [:history_search]

  def create
    @account = current_account
    @services = current_account.services
    @service = current_account.services.build(service_params)
    @service.company_id = current_company.id
    @invoice = current_account.invoices.build
    @invoices = @account.invoices.by_outstanding

    if @service.save
      redirect_to current_account, notice: 'Service was successfully created.'
    else
      render 'accounts/show'
    end
  end

  def dashboard_create
    account = current_company.accounts.find(params[:service][:account_id])
    @accounts = current_company.accounts.by_recent_activity.with_limit
    @service = account.services.build(service_params)
    @service.company_id = current_company.id

    if @service.save
      redirect_to dashboard_path, notice: "Service was successfully created for #{account.name}."
    else
      render 'dashboard/home'
    end
  end

  def edit
    @service = current_account.services.find(params[:id])
  end

  def update
    @service = current_account.services.find(params[:id])

    if @service.update_attributes(service_params)
      redirect_to_account_or_invoice
    else
      render :edit
    end
  end

  def destroy
    @service = current_account.services.find(params[:id])
    @service.destroy

    redirect_to current_account, alert: 'Service history item successfully deleted.'
  end

  def invoice
    ActiveRecord::Base.transaction do
      @account = current_account
      @service = @account.services.build
      @service.performed_on ||= Date.current
      @services = @account.services.with_limit
      @invoices = @account.invoices.by_outstanding
      @invoice = current_account.invoices.build(invoice_params)
      @invoice.company_id = current_company.id

      if @invoice.save
        @services = current_account.services
        @services.where(id: params[:service_ids]).update_all(invoice_id: @invoice.id)

        redirect_to invoice_path(@invoice), notice: "#{'Service'.pluralize(params[:service_ids].count)} successfully invoiced."
      else
        render 'accounts/show'
      end
    end
  end

  def history_search
    @account = current_account
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def service_params
    params.require(:service).permit(:memo, :performed_on, :cost)
  end

  def invoice_params
    params.require(:invoice).permit(:established_at, :sales_tax)
  end

  def redirect_to_account_or_invoice
    if params[:invoice_id] && !@service.invoice.nil?
      redirect_to edit_invoice_path(@service.invoice), notice: 'Service was successfully updated.'
    else
      redirect_to current_account, notice: 'Service was successfully updated.'
    end
  end
end
