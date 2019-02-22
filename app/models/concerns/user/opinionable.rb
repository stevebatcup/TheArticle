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

  def agree_with_post(share)
    undisagree_with_post(share)
    Opinion.create({
      user_id: self.id,
      share_id: share.id,
      decision: 'agree'
    })
  end

  def unagree_with_post(share)
    if opinion = Opinion.find_by(user_id: self.id, share_id: share.id, decision: 'agree')
      opinion.destroy
    end
  end

  def disagree_with_post(share)
    unagree_with_post(share)
    Opinion.create({
      user_id: self.id,
      share_id: share.id,
      decision: 'disagree'
    })
  end

  def undisagree_with_post(share)
    if opinion = Opinion.find_by(user_id: self.id, share_id: share.id, decision: 'disagree')
      opinion.destroy
    end
  end

  module ClassMethods
  end
end