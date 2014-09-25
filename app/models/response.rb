class Response < ActiveRecord::Base
  validates :respondent_id, presence: true
  validates :answer_choice_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :respondent_is_not_original_author

  belongs_to(
    :respondent,
    class_name: "User",
    foreign_key: :respondent_id,
    primary_key: :id
  )

  belongs_to(
    :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id
  )

  has_one(
    :question,
    through: :answer_choice,
    source: :question
  )

  def poll
    self.question.poll
  end

  def sibling_responses
    if self.id.nil?
      self.question.responses
    else
      self.question.responses.where("responses.id <> ?", self.id)
    end
  end

  private

  def respondent_has_not_already_answered_question
    repeat_response = self.sibling_responses
                          .find_by_respondent_id(respondent_id)
    if Response.exists?(repeat_response)
      errors[:repeat] << "You already answered, idiot!"
    end
  end

  def respondent_is_not_original_author
    if poll.author_id == self.respondent_id
      errors[:self_love] << "No stuffing your own box!"
    end
  end
end