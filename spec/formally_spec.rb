require 'spec_helper'
require 'manioc'
require 'uri'

class Schema < Dry::Validation::Schema
  UUID_EXP = /\A[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}\Z/
  def uuid? str
    str =~ UUID_EXP
  end
end

Formally.config.base = Schema

class User
end

class Post < Manioc.mutable(:attachment, :published)
  def published?; published; end
end

class Attachment < Manioc[:url, :uuid, :uploader]
end

class UploadAttachment < Manioc.mutable(:post, :uploader, :database)
  prepend Formally

  formally do |f|
    configure do
      define_method(:post) { f.post }

      def attachment_present?
        !post.attachment.nil?
      end

      def dimensions_match? url:
        post.attachment.url.length == url.length
      end
    end

    required(:url ).filled :str?
    optional(:uuid).filled :uuid?

    rule compatible_dimensions: [:url] do |url|
      attachment_present? > dimensions_match?(url)
    end

    validate accepting_replacements: [] do
      !post.published?
    end
  end

  attr_accessor :attachment

  def fill data
    self.attachment = Attachment.new \
      uuid:     data[:uuid] || database.uuid,
      url:      URI(data[:url]),
      uploader: uploader

    formally.after_commit do
      database.callback
    end
  end

  def save
    post.attachment = attachment
  end
end

RSpec.describe Formally do
  let(:post) { Post.new attachment: nil, published: false }
  let(:user) { User.new }
  let(:url)  { Faker::Internet.url }

  let(:attachment) {
    Attachment.new \
      uuid:     SecureRandom.uuid,
      url:      'http://google.com',
      uploader: User.new
  }

  let(:database) { double 'database', uuid: SecureRandom.uuid }

  let(:form) { UploadAttachment.new post: post, uploader: user, database: database }

  it 'can save' do
    form.fill url: url

    expect(database).to receive(:callback)

    expect(form.errors).to be_empty
    expect(form.save).to eq true

    expect(post.attachment.url).to eq URI(url)
  end

  it 'can save!' do
    form.fill

    expect(database).not_to receive(:callback)

    expect { form.save! }.to raise_error(Formally::Invalid) do |e|
      expect(e.errors[:url]).to include 'is missing'
    end
  end

  it 'can use helper methods' do
    form.fill url: url, uuid: 'invalid uuid'

    expect(form).not_to be_valid

    expect(form.errors[:uuid]).to include 'is not a valid uuid'
    expect(post.attachment).to eq nil
  end

  context 'with an attachment' do
    before :each do
      post.attachment = attachment
    end

    it 'can check against a predicate' do
      form.fill url: 'http://google.com'
      expect(form).to be_valid

      form.fill url: 'http://google.com/longer'
      expect(form).not_to be_valid
    end

    it 'can check against a rule' do
      post.published = true

      form.fill url: 'http://google.com'

      expect(form).not_to be_valid
      expect(form.errors[:accepting_replacements]).to include(/published/)
    end
  end
end
