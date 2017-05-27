class ChangePricesAmountToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :prices, :amount, :float
  end
end
