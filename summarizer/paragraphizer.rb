# paragraphizer.rb
#
# This file is was used in the generation of the Plain summary style for the
# evaluation. It is not used in the current summarizer implementation to keep
# the basic analysis process as simple as possible.

module Paragraphizer
  def self.generate_paragraph(data)
    paragraph = ""

    data[:counter_points].each_with_index do |points, index|
      p, c = points
      paragraph += Presenter.clean(p["String"]) + "\n"
    end

    data[:negated_points].each_with_index do |point, index|
      paragraph += Presenter.clean(point[1]["String"]) + "\n"
    end

    data[:related_points].each_with_index do |points, index|
      p, r = points
      paragraph += Presenter.clean(p["String"]) + "\n"
      paragraph += Presenter.clean(r["String"]) + "\n"
    end

    data[:common_points].each_with_index do |p, index|
      paragraph += Presenter.clean(p["String"]) + "\n"
    end

    data[:longer_points].each do |p|
      paragraph += Presenter.clean(p["String"]) + "\n"
    end

    data[:multiple_topic_points].each_with_index do |p, index|
      paragraph += Presenter.clean(p["String"]) + "\n"
    end

    data[:commonly_discussed_topic_points].each_with_index do |topic, index|
      topic, points = topic
      points.each_with_index do |p, index|
        paragraph += Presenter.clean(p["String"]) + "\n"
      end
    end

    data[:question_points].each_with_index do |p, index|
      paragraph += Presenter.clean(p["String"], true) + "\n"
    end

    return paragraph
  end
end
