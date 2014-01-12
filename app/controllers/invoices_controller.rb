class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin, except: [:show]
  before_filter :set_and_authorize_account

  def show
    @invoice = @account.invoices.find(params[:id])
    @services = @invoice.services
  end

  def index
    @invoices = @account.invoices.page(params[:page]).per(10)
  end

  def edit
    @invoice = @account.invoices.find(params[:id])
  end

  def update
    @invoice = @account.invoices.find(params[:id])

    if @invoice.update_attributes(params[:invoice])
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @services = @account.services
    @invoice = @account.invoices.find(params[:id])

    @services.update_all({invoice_id: nil}, {id: @invoice.services})
    @invoice.destroy

    redirect_to account_invoices_path(@account), alert: 'Invoice was successfully deleted.'
  end

  private

  def require_admin
    redirect_to account_path(current_user.account) unless current_user.is_admin?
  end

  def set_and_authorize_account
    @account = if current_user.is_admin?
                 current_company.accounts.find(params[:account_id])
               elsif current_user.account.to_param == params[:account_id]
                 current_user.account
               else
                 redirect_to account_path(current_user.account)
               end
  end
end