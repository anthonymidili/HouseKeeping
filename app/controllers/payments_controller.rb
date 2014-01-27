class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin!
  before_filter :load_invoice

  def show
    @payment = @invoice.payments.find(params[:id])
  end

  def new
    @payment = @invoice.payments.build
    @payment.received_on ||= Date.current
  end

  def create
    @payment = @invoice.payments.build(params[:payment])
    @payments = @invoice.payments
    @services = @invoice.services

    if @payment.save
      redirect_to @invoice, notice: 'Payment was successfully created.'
    else
      render 'payments/new'
    end
  end

  def edit
    @payment = @invoice.payments.find(params[:id])
  end

  def update
    @payment = @invoice.payments.find(params[:id])

    if @payment.update_attributes(params[:payment])
      redirect_to invoice_payment_path(@invoice, @payment), notice: 'Payment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @payment = @invoice.payments.find(params[:id])
    @payment.destroy

    redirect_to @invoice
  end

private

  def load_invoice
    @invoice = current_account.invoices.find(params[:invoice_id])
  end
end
