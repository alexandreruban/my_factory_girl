$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")
$LOAD_PATH << File.dirname(__FILE__)

require "active_record"
require "rspec"
require "my_factory_girl"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "test"
)

class CreateMigration < ActiveRecord::Migration[5.2]
  def up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :admin, default: false
    end

    create_table :posts do |t|
      t.string :content
      t.references :user
    end
  end
end

class User < ActiveRecord::Base
  has_many :posts

  validates :first_name, :last_name, :email, presence: true
end

class Post < ActiveRecord::Base
  belongs_to :user

  validates :content, presence: true
end
