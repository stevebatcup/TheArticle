module User::Opinionable
  def self.included(base)
    base.extend ClassMethods
  end

  def generate_opinion_groups(decision=:agree, hours=6)
    self.shares.each do |share|
      recent_opinions = Opinion.where(opinion_group_id: nil)
                            .where("opinions.created_at >= DATE_SUB(CURTIME(), INTERVAL #{hours} HOUR)")
                            .where(decision: decision)
                            .where(share_id: share.id)
                            .order("opinions.created_at DESC")
      if recent_opinions.size > 0
        body_text = OpinionGroup.generate_body_text_from_opinions(recent_opinions, decision)
        group = OpinionGroup.new({
          user_id: self.id,
          share_id: share.id,
          body: body_text,
          decision: decision
        })
        recent_opinions.each do |recent_opinion|
          group.opinions << recent_opinion
        end
        group.save
      end
    end
  end

  module ClassMethods
  end
end