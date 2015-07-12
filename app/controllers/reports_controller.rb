class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
  end

  def income
  end

  def income_accounts
    @accounts = current_company.accounts.includes(company: :invoices)
  end
end