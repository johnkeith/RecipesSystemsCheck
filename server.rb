require_relative 'helper_methods'
require 'pry'
require 'sinatra'
require 'haml'
require 'pg'

def pg_connect
  begin
    connection = PG.connect(dbname: 'recipes')
    yield(connection)
  rescue
    connection.close
  end
end

get '/' do
  redirect '/recipes'
end

get '/recipes' do
  query = 'SELECT * FROM recipes ORDER BY recipes.name'
  @recipes = pg_connect { |connection| connection.exec(query) }
  # @recipes = @recipes.sort_by { |recipe| recipe["name"] }
  haml :'recipes/index'
end

get '/recipes/:id' do
  query = 'SELECT recipes.name AS recipe_name, recipes.description, recipes.instructions, ingredients.name AS ingredient_name FROM recipes
           JOIN ingredients ON recipes.id = ingredients.recipe_id WHERE recipes.id = $1'
  @recipe_id = params[:id]
  @recipe = pg_connect { |connection| connection.exec_params(query,["#{@recipe_id}"]) }

  haml :'recipes/show'
end
