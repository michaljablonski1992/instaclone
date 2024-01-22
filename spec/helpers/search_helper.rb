module SearchHelper

  def test_search(&block)
    user1 = create(:user, full_name: 'John Smith', username: 'funny_dogs')
    user2 = create(:user, full_name: 'Jacob Smith', username: 'funny_cats')
    user3 = create(:user, full_name: 'Anne Hathaway', username: 'hathaway_official')
    user4 = create(:user, full_name: 'George Test', username: 'george_aqq')

    # array of arrays [query, results]
    queries = [
      ['john', [user1]],
      ['JoHn', [user1]],
      ['smith', [user1, user2]],
      ['_dog', [user1]],
      ['y_ca', [user2]],
      ['fun', [user1, user2]],
      ['anne', [user3]],
      ['nN', [user1, user2, user3]],
      ['1234567890qwertyy', []]
    ]
    queries.each do |d|
      yield(d)
    end
  end

end