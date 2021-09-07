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
# lets get the current wave user account details
puts ACTIVEWAVE.list_users
```


### Usage

#### 