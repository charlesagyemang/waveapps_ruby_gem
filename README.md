## ACTIVEWAVE 

#### Rails Wrapper for Waveapps [Accounting Software] GraphQL API

### Installation

#### Step 1
```ruby
gem install activewave
```

#### Step 2: Add the code below to your .env file and replace with the correct ID's
```ruby
#.env
API_TOKEN = "XXXXXXXXXXXXXXXXX"
BUSINESS_ID = "XXXXXXXXXXXXXXXXXX"
```

#### Step 3: Call it anywhere you want in the app or the script like so
```ruby
# lets get the current wave default account details
current_wave_user = ACTIVEWAVE.get_current_user
puts current_wave_user
```


## Usage

#### GET DEFAULT WAVE USER AND ID
```ruby
current_wave_user = ACTIVEWAVE.get_current_user
puts current_wave_user
```


#### LIST ALL BUSINESSES
```ruby
businesses = ACTIVEWAVE.list_all_businesses
puts businesses
```

#### LIST ALL PRODUCTS
```ruby
products = ACTIVEWAVE.list_all_products
puts products
```


#### LIST ALL CUSTOMERS
```ruby
customers = ACTIVEWAVE.list_all_customers
puts customers
```

#### LIST ALL INVOICES
```ruby
invoices = ACTIVEWAVE.list_all_invoices
puts invoices
```


#### LIST ALL ASSETS
```ruby
assets = ACTIVEWAVE.list_all_assets
puts assets
```


#### LIST ALL INCOMES
```ruby
incomes = ACTIVEWAVE.list_all_incomes
puts incomes
```


#### LIST ALL EXPENSES
```ruby
expenses = ACTIVEWAVE.list_all_expenses
puts expenses
```

#### CREATE CUSTOMER : PARAMS => ["user_name", "first_name", "last_name", "email"]
```ruby
# user_name  => Required
# first_name => Required
# last_name  => Not Required
# email => Not Required

# lets create some variables and store our user data
user_name    = "Test User Name"
first_name   = "Test First Name"
last_name    = "Test Last Name"
email        = "testemail@gmail.com"


# create customer with user_name, first_name and last_name
new_customer = ACTIVEWAVE.create_customer(user_name, first_name, last_name)
puts new_customer

# create customer with user_name, first_name, last_name and email
new_customer = ACTIVEWAVE.create_customer(user_name, first_name, last_name, email)
puts new_customer
```


#### CREATE INVOICE : PARAMS => ["customer_id", "product_id"]
```ruby
# customer_id  => Required
# product_id   => Required

# lets create some variables and store our data
customer_id    = "XXXXXXXXXXXXXXX"
product_id     = "XXXXXXXXXXXXXXX"

# create invoice with customer_id and product_id
new_invoice = ACTIVEWAVE.create_invoice(customer_id, product_id)
puts new_invoice
```


#### CREATE INCOME/SALES : PARAMS => ["date", "cash_or_bank_or_asset_account_id", "income_account_id", amount, "description"]
```ruby
#All fields are required

# lets create some variables and store our data
date                                 = Date.today
cash_or_bank_or_asset_account_id     = "XXXXXXXX"
income_account_id                    = "XXXXXXXX"
amount                               = 500
description                          = "Description"

# create income/sales with date and cash_or_bank_or_asset_account_id income_account_id amount description
new_sales_record = ACTIVEWAVE.create_sales_record(date, cash_or_bank_or_asset_account_id, income_account_id, amount, description)
puts new_sales_record
```


#### CREATE EXPENSES/SPENDING RECORD : PARAMS => ["date", "cash_or_bank_or_asset_account_id", "expense_account_id", amount, "description"]
```ruby
#All fields are required

# lets create some variables and store our data
date                                 = Date.today
cash_or_bank_or_asset_account_id     = "XXXXXXXX"
expense_account_id                   = "XXXXXXXX"
amount                               = 500
description                          = "Description"

# create expense/spending record with date and cash_or_bank_or_asset_account_id expense_account_id amount description
new_sales_record = ACTIVEWAVE.create_sales_record(date, cash_or_bank_or_asset_account_id, expense_account_id, amount, description)
puts new_sales_record
```