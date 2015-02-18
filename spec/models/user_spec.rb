# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  username                      :citext
#  name                          :string(255)
#  email                         :citext
#  location                      :string(255)
#  old_github_token              :string(255)
#  state                         :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  twitter                       :string(255)
#  linkedin_legacy               :string(255)
#  stackoverflow                 :string(255)
#  admin                         :boolean          default(FALSE)
#  backup_email                  :string(255)
#  badges_count                  :integer          default(0)
#  bitbucket                     :string(255)
#  codeplex                      :string(255)
#  login_count                   :integer          default(0)
#  last_request_at               :datetime         default(2014-07-23 03:14:36 UTC)
#  achievements_checked_at       :datetime         default(1911-08-12 21:49:21 UTC)
#  claim_code                    :text
#  github_id                     :integer
#  country                       :string(255)
#  city                          :string(255)
#  state_name                    :string(255)
#  lat                           :float
#  lng                           :float
#  http_counter                  :integer
#  github_token                  :string(255)
#  twitter_checked_at            :datetime         default(1911-08-12 21:49:21 UTC)
#  title                         :string(255)
#  company                       :string(255)
#  blog                          :string(255)
#  github                        :citext
#  forrst                        :string(255)
#  dribbble                      :string(255)
#  specialties                   :text
#  notify_on_award               :boolean          default(TRUE)
#  receive_newsletter            :boolean          default(TRUE)
#  zerply                        :string(255)
#  linkedin                      :string(255)
#  linkedin_id                   :string(255)
#  linkedin_token                :string(255)
#  twitter_id                    :string(255)
#  twitter_token                 :string(255)
#  twitter_secret                :string(255)
#  linkedin_secret               :string(255)
#  last_email_sent               :datetime
#  linkedin_public_url           :string(255)
#  redemptions                   :text
#  endorsements_count            :integer          default(0)
#  team_document_id              :string(255)
#  speakerdeck                   :string(255)
#  slideshare                    :string(255)
#  last_refresh_at               :datetime         default(1970-01-01 00:00:00 UTC)
#  referral_token                :string(255)
#  referred_by                   :string(255)
#  about                         :text
#  joined_github_on              :date
#  avatar                        :string(255)
#  banner                        :string(255)
#  remind_to_invite_team_members :datetime
#  activated_on                  :datetime
#  tracking_code                 :string(255)
#  utm_campaign                  :string(255)
#  score_cache                   :float            default(0.0)
#  gender                        :string(255)
#  notify_on_follow              :boolean          default(TRUE)
#  api_key                       :string(255)
#  remind_to_create_team         :datetime
#  remind_to_create_protip       :datetime
#  remind_to_create_skills       :datetime
#  remind_to_link_accounts       :datetime
#  favorite_websites             :string(255)
#  team_responsibilities         :text
#  team_avatar                   :string(255)
#  team_banner                   :string(255)
#  stat_name_1                   :string(255)
#  stat_number_1                 :string(255)
#  stat_name_2                   :string(255)
#  stat_number_2                 :string(255)
#  stat_name_3                   :string(255)
#  stat_number_3                 :string(255)
#  ip_lat                        :float
#  ip_lng                        :float
#  penalty                       :float            default(0.0)
#  receive_weekly_digest         :boolean          default(TRUE)
#  github_failures               :integer          default(0)
#  resume                        :string(255)
#  sourceforge                   :string(255)
#  google_code                   :string(255)
#  sales_rep                     :boolean          default(FALSE)
#  visits                        :string(255)      default("")
#  visit_frequency               :string(255)      default("rarely")
#  pitchbox_id                   :integer
#  join_badge_orgs               :boolean          default(FALSE)
#  use_social_for_pitchbox       :boolean          default(FALSE)
#  last_asm_email_at             :datetime
#  banned_at                     :datetime
#  last_ip                       :string(255)
#  last_ua                       :string(255)
#  team_id                       :integer
#

RSpec.describe User, type: :model do
  it { is_expected.to have_one :github_profile }
  it { is_expected.to have_many :github_repositories }

  before :each do
    User.destroy_all
  end

  describe 'validation' do
    it 'should not allow a username in the reserved list' do
      User::RESERVED.each do |reserved|
        user = Fabricate.build(:user, username: reserved)
        expect(user).not_to be_valid
        expect(user.errors[:username]).to eq(['is reserved'])
      end
    end

    it 'should not allow a username with a period character' do
      user = Fabricate.build(:user, username: 'foo.bar')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to eq(['must not contain a period'])
    end

    it 'should require valid email when instantiating' do
      user = Fabricate.build(:user, email: 'someting @ not valid.com', state: nil)
      expect(user.save).to be_falsey
      expect(user).not_to be_valid
      expect(user.errors[:email]).not_to be_empty
    end
  end

  it 'should create a token on creation' do
    user = Fabricate(:user)
    expect(user.referral_token).not_to be_nil
  end

  it 'should not allow the username in multiple cases to be use on creation' do
    Fabricate(:user, username: 'MDEITERS')
    expect { Fabricate(:user, username: 'mdeiters') }.to raise_error('Validation failed: Username has already been taken')
  end

  it 'should find user by username no matter the case' do
    user = Fabricate(:user, username: 'seuros')
    expect(User.find_by_username('Seuros')).to eq(user)
  end

  it 'should not return incorrect user because of pattern matching' do
    user = Fabricate(:user, username: 'MDEITERS')
    found = User.find_by_username('M_EITERS')
    expect(found).not_to eq(user)
  end

  describe '::find_by_provider_username' do
    it 'should find users by username when provider is blank' do
      user = Fabricate(:user, username: 'mdeiters')
      expect(User.find_by_provider_username('mdeiters', '')).to eq(user)
    end

    it 'should find users ignoring case' do
      user = Fabricate(:user, username: 'MDEITERS', twitter: 'MDEITERS', github: 'MDEITERS', linkedin: 'MDEITERS')
      expect(User.find_by_provider_username('mdeiters', '')).to eq(user)
      expect(User.find_by_provider_username('mdeiters', "twitter")).to eq(user)
      expect(User.find_by_provider_username('mdeiters', "github")).to eq(user)
      expect(User.find_by_provider_username('mdeiters', "linkedin")).to eq(user)
    end
  end

  it 'instantiates new user with omniauth if the user is not on file' do
    omniauth = { 'info' => { 'name' => 'Matthew Deiters', 'urls' => { 'Blog' => 'http://www.theagiledeveloper.com', 'GitHub' => 'http://github.com/mdeiters' }, 'nickname' => 'mdeiters', 'email' => '' }, 'uid' => 7330, 'credentials' => { 'token' => 'f0f6946eb12c4156a7a567fd73aebe4d3cdde4c8' }, 'extra' => { 'user_hash' => { 'plan' => { 'name' => 'micro', 'collaborators' => 1, 'space' => 614_400, 'private_repos' => 5 }, 'gravatar_id' => 'aacb7c97f7452b3ff11f67151469e3b0', 'company' => nil, 'name' => 'Matthew Deiters', 'created_at' => '2008/04/14 15:53:10 -0700', 'location' => '', 'disk_usage' => 288_049, 'collaborators' => 0, 'public_repo_count' => 18, 'public_gist_count' => 31, 'blog' => 'http://www.theagiledeveloper.com', 'following_count' => 27, 'id' => 7330, 'owned_private_repo_count' => 2, 'private_gist_count' => 2, 'type' => 'User', 'permission' => nil, 'total_private_repo_count' => 2, 'followers_count' => 19, 'login' => 'mdeiters', 'email' => '' } }, 'provider' => 'github' }

    user = User.for_omniauth(omniauth.with_indifferent_access)
    expect(user).to be_new_record
  end

  describe 'viewing' do
    it 'tracks when a user views a profile' do
      user = Fabricate :user
      viewer = Fabricate :user
      user.viewed_by(viewer)
      expect(user.viewers.first).to eq(viewer)
      expect(user.total_views).to eq(1)
    end

    it 'tracks when a user views a profile' do
      user = Fabricate :user
      user.viewed_by(nil)
      expect(user.total_views).to eq(1)
    end
  end
  describe 'badges' do
    it 'should return users with most badges' do
      user_with_2_badges = Fabricate :user, username: 'somethingelse'
      user_with_2_badges.badges.create!(badge_class_name: Mongoose3.name)
      user_with_2_badges.badges.create!(badge_class_name: Octopussy.name)

      user_with_3_badges = Fabricate :user
      user_with_3_badges.badges.create!(badge_class_name: Mongoose3.name)
      user_with_3_badges.badges.create!(badge_class_name: Octopussy.name)
      user_with_3_badges.badges.create!(badge_class_name: Mongoose.name)

      expect(User.top(1)).to include(user_with_3_badges)
      expect(User.top(1)).not_to include(user_with_2_badges)
    end

    it 'returns badges in order created with latest first' do
      user = Fabricate :user
      badge1 = user.badges.create!(badge_class_name: Mongoose3.name)
      user.badges.create!(badge_class_name: Octopussy.name)
      badge3 = user.badges.create!(badge_class_name: Mongoose.name)

      expect(user.badges.first).to eq(badge3)
      expect(user.badges.last).to eq(badge1)
    end

    class NotaBadge < BadgeBase
    end

    class AlsoNotaBadge < BadgeBase
    end

    it 'should award user with badge' do
      user = Fabricate :user
      user.award(NotaBadge.new(user))
      expect(user.badges.size).to eq(1)
      expect(user.badges.first.badge_class_name).to eq(NotaBadge.name)
    end

    it 'should not allow adding the same badge twice' do
      user = Fabricate :user
      user.award(NotaBadge.new(user))
      user.award(NotaBadge.new(user))
      user.save!
      expect(user.badges.count).to eq(1)
    end

    it 'increments the badge count when you add new badges' do
      user = Fabricate :user

      user.award(NotaBadge.new(user))
      user.save!
      user.reload
      expect(user.badges_count).to eq(1)

      user.award(AlsoNotaBadge.new(user))
      user.save!
      user.reload
      expect(user.badges_count).to eq(2)
    end

    it 'should randomly select the user with badges' do
      user = Fabricate :user
      user.award(NotaBadge.new(user))
      user.award(NotaBadge.new(user))
      user.save!

      user2 = Fabricate :user, username: 'different', github_token: 'unique'

      4.times do
        expect(User.random).not_to eq(user2)
      end
    end
  end

  describe 'redemptions' do
    it 'should have an empty list of redemptions when new' do
      expect(Fabricate.build(:user).redemptions).to be_empty
    end

    it 'should have a single redemption with a redemptions list of one item' do
      user = Fabricate.build(:user, redemptions: %w(railscampx nodeknockout))
      user.save
      expect(user.reload.redemptions).to eq(%w(railscampx nodeknockout))
    end

    it 'should allow you to add a redemption' do
      user = Fabricate.build(:user, redemptions: %w(foo))
      user.update_attributes redemptions: %w(bar)
      expect(user.reload.redemptions).to eq(%w(bar))
    end

    it 'should allow you to remove redemptions' do
      user = Fabricate.build(:user, redemptions: %w(foo))
      user.update_attributes redemptions: []
      expect(user.reload.redemptions).to be_empty
    end
  end

  describe 'score' do
    let(:user) { Fabricate(:user) }
    let(:endorser) { Fabricate(:user) }

    it 'calculates weight of badges' do
      expect(user.achievement_score).to eq(0)
      user.award(Cub.new(user))
      expect(user.achievement_score).to eq(1)
      user.award(Philanthropist.new(user))
      expect(user.achievement_score).to eq(4)
    end

    it 'should penalize by amount or 1' do
      user.award(Cub.new(user))
      expect(user.score).to eq(1)
      user.penalize!
      expect(user.reload.score).to eq(0)
      endorser.endorse(user, 'Ruby')
      endorser.endorse(user, 'C++')
      endorser.endorse(user, 'CSS')
      user.reload
      expect(user.score).to eq(0.16666666666666674)
      user.penalize!(0.3)
      expect(user.reload.score).to eq(0.866666666666667)
      user.penalize!(2.0)
      expect(user.reload.score).to eq(0)
    end
  end

  describe '#team' do
    let(:team) { Fabricate(:team) }
    let(:user) { Fabricate(:user) }

    it 'returns membership team if user has membership' do
      team.add_member(user)
      expect(user.team).to eq(team)
    end

    it 'returns team if team_id is set' do
      user.team_id = team.id
      user.save
      expect(user.team).to eq(team)
    end

    it 'returns nil if no team_id or membership' do
      expect(user.team).to eq(nil)
    end

    it 'should not error if the users team has been deleted' do
      team = Fabricate(:team)
      user = Fabricate(:user)
      team.add_member(user)
      team.destroy
      expect(user.team).to be_nil
    end
  end

  describe '#on_team?' do
    let(:team) { Fabricate(:team) }
    let(:user) { Fabricate(:user) }

    it 'is true if user has a membership' do
      expect(user.on_team?).to eq(false)
      team.add_member(user)
      expect(user.reload.on_team?).to eq(true)
    end

    it 'is true if user is on a team' do
      expect(user.on_team?).to eq(false)
      user.team = team
      user.save
      expect(user.reload.on_team?).to eq(true)
    end
  end

  describe "#on_premium_team?" do
    it 'should indicate when user is on a premium team' do
      team = Fabricate(:team, premium: true)
      member = team.add_member(user = Fabricate(:user))
      expect(user.on_premium_team?).to eq(true)
    end

    it 'should indicate a user not on a premium team when they dont belong to a team at all' do
      user = Fabricate(:user)
      expect(user.on_premium_team?).to eq(false)
    end
  end

  describe 'following users' do
    let(:user) { Fabricate(:user) }
    let(:other_user) { Fabricate(:user) }

    it 'can follow another user' do
      user.follow(other_user)

      expect(other_user.followed_by?(user)).to eq(true)
      expect(user.following?(other_user)).to eq(true)
    end

    it 'should pull twitter follow list and follow any users on our system' do
      expect(Twitter).to receive(:friend_ids).with(6_271_932).and_return(%w(1111 2222))

      user = Fabricate(:user, twitter_id: 6_271_932)
      other_user = Fabricate(:user, twitter_id: '1111')
      expect(user).not_to be_following(other_user)
      user.build_follow_list!

      expect(user).to be_following(other_user)
    end

    it 'should follow another user only once' do
      expect(user.following_by_type(User.name).size).to eq(0)
      2.times do
        user.follow(other_user)
        expect(user.following_by_type(User.name).size).to eq(1)
      end
    end
  end

  describe 'following teams' do
    let(:user) { Fabricate(:user) }
    let(:team) { Fabricate(:team) }

    it 'can follow a team' do
      user.follow_team!(team)
      user.reload
      expect(user.following_team?(team)).to eq(true)
    end

    it 'can unfollow a team' do
      user.follow_team!(team)
      user.unfollow_team!(team)
      user.reload
      expect(user.following_team?(team)).to eq(false)
    end
  end

  describe 'skills' do
    let(:user) { Fabricate(:user) }

    it 'prevents duplicate skills from being created' do
      user.add_skill('Ruby')
      user.add_skill('Ruby ')
      user.reload
      expect(user.skills.size).to eq(1)
    end

    it 'finds skill by name' do
      skill_created = user.add_skill('Ruby')
      expect(user.skill_for('ruby')).to eq(skill_created)
    end
  end

  describe 'api key' do
    let(:user) { Fabricate(:user) }

    it 'should assign and save an api_key if not exists' do
      api_key = user.api_key
      expect(api_key).not_to be_nil
      expect(api_key).to eq(user.api_key)
      user.reload
      expect(user.api_key).to eq(api_key)
    end

    it 'should assign a new api_key if the one generated already exists' do
      RandomSecure = double('RandomSecure')
      allow(RandomSecure).to receive(:hex).and_return('0b5c141c21c15b34')
      user2 = Fabricate(:user)
      api_key2 = user2.api_key
      user2.api_key = RandomSecure.hex(8)
      expect(user2.api_key).not_to eq(api_key2)
      api_key1 = user.api_key
      expect(api_key1).not_to eq(api_key2)
    end
  end

  describe 'feature highlighting' do
    let(:user) { Fabricate(:user) }

    it 'indicates when a user has not seen a feature' do
      expect(user.seen?('some_feature')).to eq(false)
    end

    it 'indicates when a user has seen a feature' do
      user.seen('some_feature')
      expect(user.seen?('some_feature')).to eq(true)
    end
  end

  describe 'banning' do
   let(:user) { Fabricate(:user) }

   it 'should respond to banned? public method' do
     expect(user.respond_to?(:banned?)).to be_truthy
   end

   it 'should not default to banned' do
     expect(user.banned?).to eq(false)
   end
 end

  describe 'deleting a user' do
    it 'deletes asosciated protips' do
      user = Fabricate(:user)
      Fabricate(:protip, user: user)

      expect(user.reload.protips).to receive(:destroy_all).and_return(false)
      user.destroy
    end
  end

end
