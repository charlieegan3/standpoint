module Paragraphizer
  def self.generate_paragraph(data)
    paragraph = ""
    data[:counter_points].each_with_index do |points, index|
      p, c = points
      paragraph += '"' + Presenter.clean(p["String"])[0..-2] + '"'
      paragraph += ", " if index < data[:counter_points].size-1
    end    

    paragraph += "\n"    

    data[:related_points].each_with_index do |points, index|
      p, r = points
      paragraph += '"' + Presenter.clean(p["String"])[0..-2] + '"'
      paragraph += ", "
      paragraph += '"' + Presenter.clean(r["String"])[0..-2] + '"'    

      paragraph += ", " if index < data[:related_points].size-1
    end    

    paragraph += "\n"    

    data[:negated_points].each_with_index do |point, index|
      paragraph += '"' + Presenter.clean(point[1]["String"]) + '"'    

      paragraph += ", " if index < data[:negated_points].size-1
    end    

    paragraph += "\n"    

    data[:common_points].each_with_index do |p, index|
      paragraph += '"' + Presenter.clean(p["String"]) + '"'    

      paragraph += ", " if index < data[:common_points].size-1
    end    

    paragraph += "\n"    

    data[:longer_points].each do |p|
      paragraph += '"' + Presenter.clean(p["String"]) + '"'
      paragraph += ", "
    end
    data[:multiple_topic_points].each_with_index do |p, index|
      paragraph += '"' + Presenter.clean(p["String"]) + '"'    

      paragraph += ", " if index < data[:multiple_topic_points].size-1
    end
    paragraph += "\n"    

    data[:commonly_discussed_topic_points].each_with_index do |topic, index|
      topic, points = topic
      points.each_with_index do |p, index|
        paragraph += '"' + Presenter.clean(p["String"]) + '"'
        paragraph += ", " if index < data[:commonly_discussed_topic_points].size-1
      end
      paragraph += "\n" unless index == data[:commonly_discussed_topic_points].size-1
    end    

    paragraph += "\n"    

    data[:question_points].each_with_index do |p, index|
      paragraph += '"' + Presenter.clean(p["String"], true) + '"'
      paragraph += ", " if index < data[:question_points].size-1
    end    

    return paragraph
  end
end
