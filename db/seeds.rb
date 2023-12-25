User.create!(name: "Example User",
            email: "example@railstutorial.org",
            password: "foobarbuzz",
            password_confirmation:"foobarbuzz",
            admin: true)

200.times do |n|
  name = Faker::Name.name
  email = Faker::Internet.email #"example-#{n+1}@railstutorial.org"
  password = "password"
  User.create(name: name,
            email: email,
            password: password,
            password_confirmation: password)
end

