
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'http'
require 'sinatra/cookies'
require 'net/http'


# Welcome route
get '/' do
  erb :welcome
end

# Form for entering food item
get '/lookup' do
  erb :lookup_form
end

class FoodNutritionInfo
  @@total_calories = 0

  def initialize(api_response)
    @calories_quantity = parse_response(api_response)
    @@total_calories += @calories_quantity.to_f if @calories_quantity != 'Calories not available'
  end

  def parse_response(api_response)
    api_response.dig('totalNutrients', 'ENERC_KCAL', 'quantity') || 'Calories not available'
  end

  def self.total_calories
    @@total_calories
  end

  def self.add_to_total_calories(calories)
    @@total_calories += calories
  end

  def self.clear_total_calories
    @@total_calories = 0
  end
end

# Process food item lookup
post '/lookup' do
  @food = params.fetch('food')

  # Perform API request to get nutrition information
  nutrition_data = fetch_nutrition_data(@food)

  # Create an instance of FoodNutritionInfo
  food_nutrition_info = FoodNutritionInfo.new(nutrition_data)

  # Display nutrition label
  erb :nutrition_label, locals: { nutrition_data: food_nutrition_info, total_calories: FoodNutritionInfo.total_calories }
end

post '/add_to_total' do
  puts "Params: #{params.inspect}"
  @food = params['food']
  new_foods = fetch_nutrition_data(@food)
  new_foods.dig('totalNutrients', 'ENERC_KCAL', 'quantity')

  # Update the total calories
  FoodNutritionInfo.add_to_total_calories(@calories_quantity)
  puts "Food: #{@food}, Calories to add: #{@calories_to_add}"
  
  # Redirect back to the nutrition label page 
  redirect '/nutrition_label'
end

post '/clear_calories' do
  FoodNutritionInfo.clear_total_calories
  redirect to('/lookup')
end

api_key = ENV.fetch("FOOD_API_KEY")
api_id = ENV.fetch("FOOD_API_ID")

def fetch_nutrition_data(food_item)
  
api_key = ENV.fetch("FOOD_API_KEY")
api_id = ENV.fetch("FOOD_API_ID")
  @food = params.fetch('food')
  puts food_item
  nutrition_url = "https://api.edamam.com/api/nutrition-data?app_id=#{api_id}&app_key=#{api_key}&nutrition-type=logging&ingr=#{@food}"


  raw_nutrition_data = HTTP.get(nutrition_url).to_s
  parsed_nutrition_data = JSON.parse(raw_nutrition_data)

  # Extract nutrition data
  @calories_quantity = parsed_nutrition_data.dig('totalNutrients', 'ENERC_KCAL', 'quantity') || 'Calories not available'
  @total_fat_quantity = parsed_nutrition_data.dig('totalNutrients', 'FAT', 'quantity') || 'Not available'


  @calories_quantity = parsed_nutrition_data.dig('totalNutrients', 'ENERC_KCAL', 'quantity') || 'Calories not available'
  @total_fat_quantity = parsed_nutrition_data.dig('totalNutrients', 'FAT', 'quantity') || 'Not available'
  @cholesterol_quantity = parsed_nutrition_data.dig('totalNutrients', 'CHOLE', 'quantity') || 'Not available'
  @sodium_quantity = parsed_nutrition_data.dig('totalNutrients', 'NA', 'quantity') || 'Not available'
  @protein_quantity = parsed_nutrition_data.dig('totalNutrients', 'PROCNT', 'quantity') || 'Not available'
  @saturated_fat_quantity = parsed_nutrition_data.dig('totalNutrients', 'FASAT', 'quantity') || 'Not available'
  @monounsaturated_fat_quantity = parsed_nutrition_data.dig('totalNutrients', 'FAMS', 'quantity') || 'Not available'
  @trans_fat_quantity = parsed_nutrition_data.dig('totalNutrients', 'FATRN', 'quantity') || 'Not available'
  @polyunsaturated_fat_quantity = parsed_nutrition_data.dig('totalNutrients', 'FAPU', 'quantity') || 'Not available'
  @carbohydrates_quantity = parsed_nutrition_data.dig('totalNutrients', 'CHOCDF', 'quantity') || 'Not available'
  @dietary_fiber_quantity = parsed_nutrition_data.dig('totalNutrients', 'FIBTG', 'quantity') || 'Not available'
  @sugars_quantity = parsed_nutrition_data.dig('totalNutrients', 'SUGAR', 'quantity') || 'Not available'
  #carbohydrates_quantity = parsed_nutrition_data.dig('totalNutrients', 'CHOCDF', 'quantity')

  
  total_daily = parsed_nutrition_data.dig('totalDaily')

  @calories_total_daily = total_daily&.dig('ENERC_KCAL', 'quantity') || 'Not available'
  @total_fat_total_daily = total_daily&.dig('FAT', 'quantity') || 'Not available'
  @cholesterol_total_daily = total_daily&.dig('CHOLE', 'quantity') || 'Not available'
  @sodium_total_daily = total_daily&.dig('NA', 'quantity') || 'Not available'
  @protein_total_daily = total_daily&.dig('PROCNT', 'quantity') || 'Not available'
  @saturated_fat_total_daily = total_daily&.dig('FASAT', 'quantity') || 'Not available'
  @monounsaturated_fat_total_daily = total_daily&.dig('FAMS', 'quantity') || 'Not available'
  @trans_fat_total_daily = total_daily&.dig('FATRN', 'quantity') || 'Not available'
  @polyunsaturated_fat_total_daily = total_daily&.dig('FAPU', 'quantity') || 'Not available'
  @monounsaturated_fat_total_daily = total_daily&.dig('FAMS', 'quantity') || 'Not available'
  @carbohydrates_total_daily = total_daily&.dig('CHOCDF', 'quantity') || 'Not available'
  @dietary_fiber_total_daily = total_daily&.dig('FIBTG', 'quantity') || 'Not available'
  @sugars_daily_value = total_daily&.dig('SUGAR', 'quantity') || 'Not available'



# Round the quantities to the nearest integer
  @calories_quantity = @calories_quantity.to_f.round
  @total_fat_quantity = @total_fat_quantity.to_f.round
  @cholesterol_quantity = @cholesterol_quantity.to_f.round
  @sodium_quantity = @sodium_quantity.to_f.round
  @protein_quantity = @protein_quantity.to_f.round
  @saturated_fat_quantity = @saturated_fat_quantity.to_f.round
  @monounsaturated_fat_quantity = @monounsaturated_fat_quantity.to_f.round
  @trans_fat_quantity = @trans_fat_quantity.to_f.round
  @polyunsaturated_fat_quantity = @polyunsaturated_fat_quantity.to_f.round
  @carbohydrates_quantity = @carbohydrates_quantity.to_f.round
  @dietary_fiber_quantity = @dietary_fiber_quantity.to_f.round
  @sugars_quantity = @sugars_quantity.to_f.round

# Round the total daily values to the nearest integer
@calories_total_daily = @calories_total_daily.to_f.round
@total_fat_total_daily = @total_fat_total_daily.to_f.round
@cholesterol_total_daily = @cholesterol_total_daily.to_f.round
@sodium_total_daily = @sodium_total_daily.to_f.round
@protein_total_daily = @protein_total_daily.to_f.round
@saturated_fat_total_daily = @saturated_fat_total_daily.to_f.round
@monounsaturated_fat_total_daily = @monounsaturated_fat_total_daily.to_f.round
@trans_fat_total_daily = @trans_fat_total_daily.to_f.round
@polyunsaturated_fat_total_daily = @polyunsaturated_fat_total_daily.to_f.round
@carbohydrates_total_daily = @carbohydrates_total_daily.to_f.round
@dietary_fiber_total_daily = @dietary_fiber_total_daily.to_f.round
@sugars_daily_value = @sugars_daily_value.to_f.round


  return parsed_nutrition_data
end
