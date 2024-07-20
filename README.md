## Coffee Ordering Lambda Backend Application

Simple Application for ordering coffee with lambda

### Endpoints:

- POST: `/orders`
  - Body (json):
    - personName: string
      - Name of person ordering the coffee
    - coffeeType: 'Flat White' | 'Latte' | 'Black' | 'Iced'
      - Type of coffee being ordered
    - milkType: 'Oat' | 'Soy' | 'Almond' | 'Rice'
      - Type of milk in the coffee
  - Returns (json):
    - personName: string
      - Name of person ordering the coffee
    - coffeeType: 'Flat White' | 'Latte' | 'Black' | 'Iced'
      - Type of coffee being ordered
    - milkType: 'Oat' | 'Soy' | 'Almond' | 'Rice'
      - Type of milk in the coffee
    - id: uuid
      - ID of the coffee order saved in DynamoDB
- GET: `/orders/{id}`
  - Returns:
    - personName: string
      - Name of person ordering the coffee
    - coffeeType: 'Flat White' | 'Latte' | 'Black' | 'Iced'
      - Type of coffee being ordered
    - milkType: 'Oat' | 'Soy' | 'Almond' | 'Rice'
      - Type of milk in the coffee
    - id: uuid
      - ID of the coffee order saved in DynamoDB
- PATCH: `/orders/{id}`
  - Body (json):
    - personName: string (optional)
      - Name of person ordering the coffee
    - coffeeType: 'Flat White' | 'Latte' | 'Black' | 'Iced' (optional)
      - Type of coffee being ordered
    - milkType: 'Oat' | 'Soy' | 'Almond' | 'Rice' (optional)
      - Type of milk in the coffee
  - Returns:
    - Successfully Updated
    - Error
- DELETE: `/orders/{id}`
  - Returns
    - Item Deleted
    - Error

### Build Steps

1. On Windows, run the Powershell script in the root directory `./scripts/build.ps1`
2. Initialise terraform `terraform init`
3. Apply the changes with terraform `terraform apply`
4. Use the endpoints
