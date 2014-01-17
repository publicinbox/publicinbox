module FormatHelper
  def readable_date(date)
    date.strftime('%A, %B %d, %Y')
  end
end
