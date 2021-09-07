require 'httparty'
require 'json'
require "uri"
require "net/http"
require 'dotenv'
Dotenv.load

module ACTIVEWAVE

  WAVE_API_URL = ENV['WAVE_API_URL']
  BUSINESS_ID  = ENV['BUSINESS_ID']
  API_TOKEN    = ENV['API_TOKEN']

  url = URI(WAVE_API_URL)

  @@https = Net::HTTP.new(url.host, url.port)
  @@https.use_ssl = true

  @@request = Net::HTTP::Post.new(url)
  @@request["Authorization"] = "Bearer #{API_TOKEN}"
  @@request["Content-Type"] = "application/json"

  LIST_ALL_PRODUCTS_QUERY = %{
       business(id: "#{BUSINESS_ID}") {
        id
        products(page: 1, pageSize: 100) {
          pageInfo {
            currentPage
            totalPages
            totalCount
          }
          edges {
            node {
              id
              name
              description
              unitPrice
              defaultSalesTaxes {
                id
                name
                abbreviation
                rate
              }
              isSold
              isBought
              isArchived
              createdAt
              modifiedAt
            }
          }
        }
      }
     }

  LIST_CUSTOMERS_QUERY = %{
    business(id: "#{BUSINESS_ID}") {
     id
     customers(page: 1, pageSize: 100, sort: [NAME_ASC]) {
       pageInfo {
         currentPage
         totalPages
         totalCount
       }
       edges {
         node {
           id
           name
           email
         }
       }
     }
   }
  }

  LIST_ALL_INVOICES_QUERY = %{
    business(id: "#{BUSINESS_ID}") {
     id
     isClassicInvoicing
     invoices(page: 0, pageSize: 100) {
       pageInfo {
         currentPage
         totalPages
         totalCount
       }
       edges {
         node {
           id
           createdAt
           modifiedAt
           pdfUrl
           viewUrl
           status
           title
           subhead
           invoiceNumber
           invoiceDate
           poNumber
           customer {
             id
             name
             # Can add additional customer fields here
           }
           currency {
             code
           }
           dueDate
           amountDue {
             value
             currency {
               symbol
             }
           }
           amountPaid {
             value
             currency {
               symbol
             }
           }
           taxTotal {
             value
             currency {
               symbol
             }
           }
           total {
             value
             currency {
               symbol
             }
           }
           exchangeRate
           footer
           memo
           disableCreditCardPayments
           disableBankPayments
           itemTitle
           unitTitle
           priceTitle
           amountTitle
           hideName
           hideDescription
           hideUnit
           hidePrice
           hideAmount
           items {
             product {
               id
               name
               # Can add additional product fields here
             }
             description
             quantity
             price
             subtotal {
               value
               currency {
                 symbol
               }
             }
             total {
               value
               currency {
                 symbol
               }
             }
             account {
               id
               name
               subtype {
                 name
                 value
               }
               # Can add additional account fields here
             }
             taxes {
               amount {
                 value
               }
               salesTax {
                 id
                 name
                 # Can add additional sales tax fields here
               }
             }
           }
           lastSentAt
           lastSentVia
           lastViewedAt
         }
       }
     }
   }
  }


  LIST_BUSINESSES = %{
      businesses(page: 1, pageSize: 10) {
      pageInfo {
        currentPage
        totalPages
        totalCount
      }
      edges {
        node {
          id
          name
          isClassicAccounting
          isClassicInvoicing
          isPersonal
        }
      }
    }
  }

  LIST_USERS = %{
    user {
      id
      defaultEmail
    }
  }


  def self.create_customer(name, first_name, last_name, email=nil)
    create_a_customer(name, first_name, last_name, email)
  end

  def self.create_invoice(driver_id, product_id, status="SAVED")
    create_an_invoice(driver_id, product_id, status)
  end


  def self.create_sales_record(date, anchor_account_id, line_item_account_id, amount, desc)
    create_a_transaction(date, anchor_account_id, line_item_account_id, amount, desc)
  end

  def self.create_expense_record(date, anchor_account_id, line_item_account_id, amount, desc)
    create_a_transaction(date, anchor_account_id, line_item_account_id, amount, desc, "EXPENSES")
  end

  def self.list_users
    execute(LIST_USERS)
  end

  def self.list_all_products
    execute(LIST_ALL_PRODUCTS_QUERY)
  end

  def self.list_all_customers
    execute(LIST_CUSTOMERS_QUERY)
  end

  def self.list_all_invoices
    execute(LIST_ALL_INVOICES_QUERY)
  end

  def self.list_all_businesses
    execute(LIST_BUSINESSES)
  end

  def self.list_all_assets
    list_assets_or_liabilities()
  end

  def self.list_all_incomes
    list_assets_or_liabilities("INCOME")
  end

  def self.list_all_expenses
    list_assets_or_liabilities("EXPENSE")
  end

  private
    def self.create_a_transaction(date, anchor_account_id, line_item_account_id, amount, desc, type="SALES")
      action = {SALES: ["DEPOSIT", "INCREASE"], EXPENSES: ["WITHDRAWAL", "INCREASE"]}
      current_action = action[type.to_sym]
      @@request.body = "{\"query\":\"  mutation ($input:MoneyTransactionCreateInput!){\\n    moneyTransactionCreate(input:$input){\\n      didSucceed\\n      inputErrors{\\n        path\\n        message\\n        code\\n      }\\n      transaction{\\n        id\\n      }\\n    }\\n  }\",\"variables\":{\"input\":{\"businessId\":\"#{BUSINESS_ID}\",\"externalId\":\"#{desc + Time.now.to_s}\",\"date\":\"#{date}\",\"description\":\"#{desc}\",\"anchor\":{\"accountId\":\"#{anchor_account_id}\",\"amount\":#{amount},\"direction\":\"#{current_action[0]}\"},\"lineItems\":[{\"accountId\":\"#{line_item_account_id}\",\"amount\":#{amount},\"balance\":\"#{current_action[1]}\"}]}}}"
      response = @@https.request(@@request)
      response.read_body
    end

    def self.create_an_invoice(driver_id, product_id, status="SAVED")
      @@request.body = "{\"query\":\"mutation ($input: InvoiceCreateInput!) {\\n  invoiceCreate(input: $input) {\\n    didSucceed\\n    inputErrors {\\n      message\\n      code\\n      path\\n    }\\n    invoice {\\n      id\\n      createdAt\\n      modifiedAt\\n      pdfUrl\\n      viewUrl\\n      status\\n      title\\n      subhead\\n      invoiceNumber\\n      invoiceDate\\n      poNumber\\n      customer {\\n        id\\n        name\\n        # Can add additional customer fields here\\n      }\\n      currency {\\n        code\\n      }\\n      dueDate\\n      amountDue {\\n        value\\n        currency {\\n          symbol\\n        }\\n      }\\n      amountPaid {\\n        value\\n        currency {\\n          symbol\\n        }\\n      }\\n      taxTotal {\\n        value\\n        currency {\\n          symbol\\n        }\\n      }\\n      total {\\n        value\\n        currency {\\n          symbol\\n        }\\n      }\\n      exchangeRate\\n      footer\\n      memo\\n      disableCreditCardPayments\\n      disableBankPayments\\n      itemTitle\\n      unitTitle\\n      priceTitle\\n      amountTitle\\n      hideName\\n      hideDescription\\n      hideUnit\\n      hidePrice\\n      hideAmount\\n      items {\\n        product {\\n          id\\n          name\\n          # Can add additional product fields here\\n        }\\n        description\\n        quantity\\n        price\\n        subtotal {\\n          value\\n          currency {\\n            symbol\\n          }\\n        }\\n        total {\\n          value\\n          currency {\\n            symbol\\n          }\\n        }\\n        account {\\n          id\\n          name\\n          subtype {\\n            name\\n            value\\n          }\\n          # Can add additional account fields here\\n        }\\n        taxes {\\n          amount {\\n            value\\n          }\\n          salesTax {\\n            id\\n            name\\n            # Can add additional sales tax fields here\\n          }\\n        }\\n      }\\n      lastSentAt\\n      lastSentVia\\n      lastViewedAt\\n    }\\n  }\\n}\",\"variables\":{\"input\":{\"businessId\":\"#{BUSINESS_ID}\",\"customerId\":\"#{driver_id}\",\"items\":[{\"productId\":\"#{product_id}\"}], \"status\":\"#{status}\"}}}"
      response = @@https.request(@@request)
      response.read_body
    end


    def self.create_a_customer(name, first_name, last_name, email)
      @@request.body = "{\"query\":\"mutation ($input: CustomerCreateInput!) {\\n  customerCreate(input: $input) {\\n    didSucceed\\n    inputErrors {\\n      code\\n      message\\n      path\\n    }\\n    customer {\\n      id\\n      name\\n      firstName\\n      lastName\\n      email\\n      address {\\n        addressLine1\\n        addressLine2\\n        city\\n        province {\\n          code\\n          name\\n        }\\n        country {\\n          code\\n          name\\n        }\\n        postalCode\\n      }\\n      currency {\\n        code\\n      }\\n    }\\n  }\\n}\",\"variables\":{\"input\":{\"businessId\":\"#{BUSINESS_ID}\",\"name\":\"#{name}\",\"firstName\":\"#{first_name}\",\"lastName\":\"#{last_name}\",\"email\":\"#{email}\",\"currency\":\"GHS\"}}}"
      response = @@https.request(@@request)
      response.read_body
    end


    def self.list_assets_or_liabilities(filter="ASSET")
      @@request.body = "{\"query\":\"query ($businessId: ID!, $page: Int!, $pageSize: Int!) {\\n  business(id: $businessId) {\\n    id\\n    accounts(page: $page, pageSize: $pageSize, types: [#{filter}]) {\\n      pageInfo {\\n        currentPage\\n        totalPages\\n        totalCount\\n      }\\n      edges {\\n        node {\\n          id\\n          name\\n          description\\n          displayId\\n          type {\\n            name\\n            value\\n          }\\n          subtype {\\n            name\\n            value\\n          }\\n          normalBalanceType\\n          isArchived\\n        }\\n      }\\n    }\\n  }\\n}\",\"variables\":{\"businessId\":\"#{BUSINESS_ID}\",\"page\":1,\"pageSize\":100}}"
      response = @@https.request(@@request)
      response.read_body
    end



    def self.execute(query)
      HTTParty.post(
        WAVE_API_URL,
        headers: {
          'Content-Type'  => 'application/json',
          'Authorization' => "Bearer #{API_TOKEN}"
        },
        body: {
          query: "{#{query}}"
        }.to_json
      )
    end

end
