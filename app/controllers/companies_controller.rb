class CompaniesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin!
  before_filter :only_one_company, only: [:new, :create]
  before_filter :set_view_quarter_cookie, only: [:quarterly_report]

  def show
    @company = current_company
  end

  def new
    @company = current_user.build_company
  end

  def create
    @company = current_user.build_company(params[:company])

    if @company.save && current_user.save
      redirect_to company_path, notice: 'Company was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @company = current_company
  end

  def update
    @company = current_company

      if @company.update_attributes(params[:company])
        redirect_to company_path, notice: 'Company was successfully updated.'
      else
        render action: 'edit'
      end
  end

  def destroy
    @company = current_company
    @company.destroy
    redirect_to new_company_path
  end

  def quarterly_report
    @accounts = current_company.accounts
  end

  def yearly_report
    @accounts = current_company.accounts
  end

  def delete_user
    @user = current_company.users.find(params[:id])
    @user.destroy
    redirect_to company_path
  end

  def search_invoices
    @invoices = current_company.invoices.order('id DESC').limit(100).page(params[:page]).per(10)
    @invoice = current_company.invoices.find_by_id(params[:search])

    found_invoice if params[:search]
  end

private

  def only_one_company
    redirect_to edit_company_path if current_company
  end

  def set_view_quarter_cookie
    @set_view_quarter_cookie ||=
        cookies[:view_quarter] = params[:view_quarter] if params[:view_quarter]
  end

  def found_invoice
    if @invoice
      redirect_to invoice_path(@invoice, account_id: @invoice.account_id),
                  notice: 'Here is the Invoice you requested.'
    else
      flash[:alert] = "Could not find Invoice# #{params[:search]}."
      render 'search_invoices'
    end
  end
end
