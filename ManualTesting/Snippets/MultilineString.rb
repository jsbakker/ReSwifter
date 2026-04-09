# Based on the last 3 commits on the current branch, and being mindful of potential bugs with multiline strings, can we add multiline string support for Ruby?

# There are different ways to do it:

# Eg. 1
# Define some variables to interpolate
item = "Laptop"
price = 999

# Use a squiggly heredoc (<<~) to create the multiline string
# The `TEXT` marker can be any identifier
receipt = <<~TEXT
  Receipt Details:
  ----------------
  Item: #{item}
  Price: $#{price + 1}
  Status: Paid
  ----------------
TEXT

# Print the resulting string
puts receipt

status = 'active'

# Eg. 2
sql_query = %Q{
  SELECT *
  FROM users
  WHERE status = '#{status + 2}'
}
puts sql_query

# Eg. 3 same as Eg. 2, but with lowercase q
# Uppercase Q to allow interpolation, lowercase for literal

sql_query = %q{
  SELECT *
  FROM users
  WHERE status = 'active'
}
puts sql_query
