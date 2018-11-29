$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")

require "active_record"
require "rspec"
require "my_factory_girl"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: File.join(File.dirname(__FILE__), "test.db")
)

class CreateSchema < ActiveRecord::Migration[5.2]
  def up
    create_table :users, force: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :admin, default: false
    end

    create_table :posts, force: true do |t|
      t.string :content
      t.integer :author_id
    end
  end
end

CreateSchema.suppress_messages { CreateSchema.migrate(:up) }

class User < ActiveRecord::Base
  has_many :posts, foreign_key: "author_id"

  validates :first_name, :last_name, :email, presence: true
end

class Post < ActiveRecord::Base
  belongs_to :author, class_name: "User"

  validates :content, presence: true
end
