require File.expand_path('../../test_unit_helper', __FILE__)

class OrganizationUnitTest < ModelTestCase

  shared "valid organization" do
    test "should be valid" do
      assert_equal true, @organization.valid?
    end
  end

  shared "invalid organization" do
    test "should not be valid" do
      assert_equal false, @organization.valid?
    end
  end

  shared "organization.name can't be empty" do
    test "should have error on text" do
      @organization.valid?
      assert_include :name, @organization.errors.errors
      assert_include "can't be empty", @organization.errors.errors[:name]
    end
  end

  shared "organization.url must be absolute" do
    test "should have error on url - must be absolute" do
      @organization.valid?
      assert_include :url, @organization.errors.errors
      assert_include "URI must be absolute", @organization.errors.errors[:url]
    end
  end

  shared "organization.url must be http, https, or ftp" do
    test "should have error on url - must be http, https, or ftp" do
      @organization.valid?
      assert_include :url, @organization.errors.errors
      assert_include "URI scheme must be http, https, or ftp",
        @organization.errors.errors[:url]
    end
  end

  context "Organization" do
    before do
      @valid_params = {
        :name     => "Department of Commerce",
        :org_type => "governmental"
      }
    end

    context "missing name" do
      before do
        @organization = Organization.new(@valid_params.merge(:name => ""))
      end

      use "invalid organization"
      use "organization.name can't be empty"
    end

    context "incorrect org_type" do
      before do
        @organization = Organization.new(@valid_params.merge(
          :org_type => "big"))
      end

      use "invalid organization"

      test "invalid org_type" do
        @organization.valid?
        expected = { :org_type => [
          "must be one of: commercial, governmental, not-for-profit"] }
        assert_equal expected, @organization.errors.errors
      end
    end

    context "correct params" do
      before do
        @organization = Organization.new(@valid_params)
      end

      use "valid organization"
    end

    context "slug" do
      context "new" do
        before do
          @organization = Organization.new(@valid_params)
        end

        after do
          @organization.destroy
        end

        test "on validation, not set" do
          assert_equal true, @organization.valid?
          assert_equal nil, @organization.slug
        end

        test "on save, set based on name" do
          assert_equal true, @organization.save
          assert_equal "department-of-commerce", @organization.slug
        end

        test "on save, set based on acronym if present" do
          @organization.acronym = "DOC"
          assert_equal true, @organization.save
          assert_equal "doc", @organization.slug
        end
      end

      context "create" do
        before do
          @organization = Organization.create(@valid_params)
        end

        after do
          @organization.destroy
        end

        test "set based on name" do
          assert_equal "department-of-commerce", @organization.slug
        end
      end

      context "create with parent" do
        before do
          @texas = Organization.create({
            :name        => "Texas",
            :org_type    => "governmental",
          })
          @sac = Organization.create({
            :name      => "Sunset Advisory Commission",
            :org_type  => "governmental",
            :parent_id => @texas.id,
          })
          @wdms = Organization.create({
            :name      => "Wildlife Damage Management Service",
            :acronym   => "WDMS",
            :org_type  => "governmental",
            :parent_id => @texas.id,
          })
        end

        after do
          @sac.destroy
          @wdms.destroy
          @texas.destroy
        end

        test "add suffix based on name correctly" do
          assert_equal "sunset-advisory-commission", @sac.slug
          assert_equal "Sunset Advisory Commission", @sac.name
        end

        test "add suffix based on acronym correctly" do
          assert_equal "wdms", @wdms.slug
          assert_equal "Wildlife Damage Management Service", @wdms.name
          assert_equal "WDMS", @wdms.acronym
        end
      end

      context "update" do
        before do
          @organization = Organization.new(@valid_params)
        end

        after do
          @organization.destroy
        end

        test "unchanged after multiple saves" do
          @organization.save
          assert_equal "department-of-commerce", @organization.slug
          @organization.save
          assert_equal "department-of-commerce", @organization.slug
        end

        test "disallow duplicate slugs" do
          @organization.slug = "in-use"
          @organization.save
          @new_organization = Organization.new(@valid_params)
          @new_organization.slug = "in-use"
          assert_equal false, @new_organization.valid?
          expected = { :slug => ["has already been taken"] }
          assert_equal expected, @new_organization.errors.errors
        end

        test "prevent duplicate slugs" do
          params = @valid_params.merge(:name => "Common")
          @organization = Organization.create(params)

          organization_2 = Organization.create!(params)
          assert_equal "common-2", organization_2.slug

          organization_3 = Organization.create!(params)
          assert_equal "common-3", organization_3.slug

          organization_2.destroy
          organization_3.destroy
        end
      end
    end

    context "url" do
      context "http with port" do
        before do
          @organization = Organization.new(@valid_params.merge(
            :url => "http://www.commerce.gov:80"))
        end

        use "valid organization"
      end

      context "ftp" do
        before do
          @organization = Organization.new(@valid_params.merge(
            :url => "ftp://commerce.gov"))
        end

        use "valid organization"
      end

      context "wacky" do
        before do
          @organization = Organization.new(@valid_params.merge(
            :url => "wacky://commerce.gov"))
        end

        use "invalid organization"
        use "organization.url must be http, https, or ftp"
      end

      context "relative" do
        before do
          @organization = Organization.new(@valid_params.merge(
           :url => "/just/a/path"))
        end

        use "invalid organization"
        use "organization.url must be absolute"
      end
    end
  end

  context "slugs scoped by top level org" do
    before do
      @texas = Organization.create!({
        :name        => "Texas",
        :org_type    => "governmental",
        :top_level   => true,
      })
      @texas_auditor = Organization.create!({
        :name      => "Texas",
        :org_type  => "governmental",
        :name      => "State Auditor",
        :parent_id => @texas.id
      })
    end

    after do
      @texas_auditor.destroy
      @texas.destroy
    end

    context "same parent, duplicate slug" do
      before do
        @org_params = {
          :name      => "State Auditor",
          :org_type  => "governmental",
          :parent_id => @texas.id,
        }
      end

      test "fail validation" do
        org = Organization.new(@org_params.merge({
          :slug => 'state-auditor'
        }))
        assert_equal false, org.valid?
      end

      test "adjust on create" do
        org = Organization.create!(@org_params)
        assert_equal "state-auditor-2", org.slug
        org.destroy
      end
    end

    context "different parent, duplicate slug" do
      before do
        @ohio = Organization.create!({
          :name        => "Ohio",
          :org_type    => "governmental",
          :top_level   => true,
        })
        @org_params = {
          :name      => "State Auditor",
          :org_type  => "governmental",
          :parent_id => @ohio.id,
        }
      end

      after do
        @ohio.destroy
      end

      test "pass validation" do
        org = Organization.new(@org_params.merge({
          :slug => 'state-auditor'
        }))
        assert_equal true, org.valid?
      end

      test "keep slug after create" do
        org = Organization.create!(@org_params)
        assert_equal "state-auditor", org.slug
        org.destroy
      end
    end
  end

  context "three organization levels" do
    before do
      @texas = Organization.create!({
        :name        => "Texas",
        :org_type    => "governmental",
        :top_level   => true,
      })
      @austin = Organization.create!({
        :name        => "Austin, Texas",
        :slug        => "austin",
        :org_type    => "governmental",
        :parent_id   => @texas.id,
      })
      @greenville_tx = Organization.create!({
        :name      => "Greenville, TX",
        :slug      => "greenville",
        :org_type  => "governmental",
        :parent_id => @texas.id,
      })
    end

    after do
      @greenville_tx.destroy
      @austin.destroy
      @texas.destroy
    end

    test "correct top_parent_id" do
      assert_equal @texas.id, @texas.top_parent_id
      assert_equal @texas.id, @austin.top_parent_id
      assert_equal @texas.id, @greenville_tx.top_parent_id
    end

    test "correct top_parent" do
      assert_equal @texas, @texas.top_parent
      assert_equal @texas, @austin.top_parent
      assert_equal @texas, @greenville_tx.top_parent
    end
  end

end
