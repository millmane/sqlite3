require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class  Users
attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']

  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      where
        id = ?
      SQL
      raise 'unknown id' if user[0].nil?
      p user
    Users.new(user[0])
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    where
      fname = ? AND lname = ?
      SQL
    Users.new(user[0])
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    Replies.find_by_author_id(@id)
  end

  def followed_questions
    QuestionFollows.find_by_user_id(@id)
  end

end

class Questions
  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @author_id = options['author_id']
    @body = options['body']
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      where
        id = ?
      SQL
      raise 'unknown id' if question.empty?
      Questions.new(question.first)
      #question.map { |question| Questions.new(question) }
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
      SQL
      question.map { |question| Questions.new(question)}
  end

  def author
    Users.find_by_id(@author_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

end

class QuestionFollows
  attr_reader :user_id
  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    question_follows = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      where
        id = ?
      SQL
      raise 'unknown id' if question_follows.empty?

      QuestionFollows.new(question_follows.first)
  end

  def self.find_by_user_id(id)
    question_follows = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      where
        user_id = ?
      SQL
      raise 'unknown id' if question_follows.empty?
      p question_follows
      question_follows.map { |follows| QuestionFollows.new(follows) }
  end

  def self.find_by_question_id(id)
    question_follows = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      where
        question_id = ?
      SQL
      raise 'unknown id' if question_follows.empty?
      p question_follows
      question_follows.map { |follows| QuestionFollows.new(follows) }

  end

  def self.followers_for_question_id(question_id)
    follows = QuestionFollows.find_by_question_id(question_id)
    follows.map {|follow| Users.find_by_id(follow.user_id) }
  end

  def self.followed_questions_for_user_id(user_id)
    follows = QuestionFollows.find_by_user_id(user_id)
    follows.map { |follow| Questions.find_by_author_id(follow.user_id)}
  end
end

class QuestionLikes
  def self.find_by_id(id)
    question_likes = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      where
        id = ?
      SQL
      raise 'unknown id' if question_likes[0].nil?
    QuestionLikes.new(question_likes[0])
  end
end

class Replies
  def initialize(options = {})
    @id = options['id']
    @question_id = options['question_id']
    @author_id = options['author_id']
    @parent_id = options['parent_id']
    @body = options['body']
  end

  def self.find_by_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL

    Replies.new(replies.first)
  end

  def self.find_by_author_id(author_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      where
        author_id = ?
      SQL
      raise 'unknown id' if replies.empty?
    replies.map {|reply| Replies.new(reply)}
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      where
        question_id = ?
      SQL
      raise 'unknown id' if replies[0].nil?

      replies.map { |reply| Replies.new(reply) }
  end

  def author
    Users.find_by_id(@author_id)
  end

  def question
    Questions.find_by_id(@question_id)
  end

  def parent_reply
    Replies.find_by_id(@parent_id)
  end

  def child_replies
    Replies.find_by_id(@id + 1)
  end

end
