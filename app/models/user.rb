class User < ActiveRecord::Base
  validates :user_name, uniqueness: true, presence: true

  has_many(
    :authored_polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id
  )

  has_many(
    :responses,
    class_name: "Response",
    foreign_key: :respondent_id,
    primary_key: :id
  )

  has_many(
    :authored_questions,
    through: :authored_polls,
    source: :questions
  )

  def completed_polls
    polls = self
            .responses
            .select("questions.poll_id poll_id")
            .joins(:question)
            .group("questions.poll_id")
            .having("Count(responses.id) = Count(questions.id)")
            .map{|response| response.poll_id }
  end

  # def completed_polls # find_by_sql version
  #   Poll.find_by_sql([<<-SQL, self.id])
  #   SELECT
  #     questions_per_poll.id
  #   FROM (
  #     SELECT
  #       polls.*, COUNT(questions.id) AS question_count
  #     FROM
  #       polls
  #     INNER JOIN
  #       questions
  #     ON
  #       polls.id = questions.poll_id
  #     GROUP BY
  #       polls.id
  #   ) AS questions_per_poll
  #   INNER JOIN (
  #     SELECT
  #       questions.poll_id, COUNT(user_responses.id) AS response_count
  #     FROM (
  #       SELECT
  #         responses.*
  #       FROM
  #         responses
  #       WHERE
  #         responses.respondent_id = ?
  #     ) AS user_responses
  #     INNER JOIN
  #       answer_choices
  #     ON
  #       user_responses.answer_choice_id = answer_choices.id
  #     INNER JOIN
  #       questions
  #     ON
  #       answer_choices.question_id = questions.id
  #     GROUP BY
  #       questions.poll_id
  #   ) AS responses_per_poll
  #   ON
  #     responses_per_poll.poll_id = questions_per_poll.id
  #   WHERE
  #     responses_per_poll.response_count = questions_per_poll.question_count
  #   SQL
  # end
end

