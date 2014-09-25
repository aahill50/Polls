class Question < ActiveRecord::Base
  validates :poll_id, presence: true
  validates :inquiry, presence: true, uniqueness: true

  belongs_to(
    :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id
  )

  has_many(
    :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id
  )

  has_many(
    :responses,
    through: :answer_choices,
    source: :responses
  )

  # def results # (N + 1)
#     results = Hash.new(0)
#
#     self.responses.each do |response|
#       results[response.answer_choice.answer_choice_text] += 1
#     end
#
#     results
#   end

  # def results #Prefetch version
  #   results = Hash.new(0)
  #   responses = self.responses.includes(:answer_choice)
  #
  #   responses.each do |response|
  #     results[response.answer_choice.answer_choice_text] += 1
  #   end
  #   results
  # end

  def results
    answers = self
      .answer_choices
      .select("answer_choices.*, COUNT(responses.id) response_count")
      .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
      .where("answer_choices.question_id = ?", self.id)
      .group("answer_choices.id")

    answer_hash = Hash.new(0)
    answers.each do |answer|
      answer_hash[answer.answer_choice_text] = answer.response_count
    end

    answer_hash
  end

end