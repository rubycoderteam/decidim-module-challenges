# frozen_string_literal: true

module Decidim
  module Solutions
    # Controller that allows browsing solutions.
    #
    class SolutionsController < Decidim::Solutions::ApplicationController
      include Decidim::ApplicationHelper
      include FilterResource
      include Paginable
      include OrderableSolutions
      include Decidim::Sdgs::SdgsHelper

      helper Decidim::CheckBoxesTreeHelper
      helper Decidim::Sdgs::SdgsHelper

      helper_method :solutions

      def index; end

      def show
        @solution = solution
        @sdg_index = sdg_index if @solution.problem.challenge.sdg_code.present?
        @challenge_scope = challenge_scope
        @sectorial_scope = sectorial_scope
        @technological_scope = technological_scope
      end

      private

      def default_filter_params
        {
          search_text: "",
          category_id: default_filter_category_params,
          territorial_scope_id: default_filter_scope_params,
          related_to: "",
          sdgs_codes: [],
        }
      end

      def default_filter_category_params
        return "all" unless current_component.participatory_space.categories.any?

        ["all"] + current_component.participatory_space.categories.map { |category| category.id.to_s }
      end

      def default_filter_scope_params
        return "all" unless current_component.participatory_space.scopes.any?

        if current_component.participatory_space.scope
          ["all", current_component.participatory_space.scope.id] + current_component.participatory_space.scope.children.map { |scope| scope.id.to_s }
        else
          %w(all global) + current_component.participatory_space.scopes.map { |scope| scope.id.to_s }
        end
      end

      def solutions
        @solutions ||= paginate(search.results.published)
      end

      def solution
        @solution ||= Solution.find(params[:id])
      end

      def sdg_index
        @sdg_index ||= (1 + Decidim::Sdgs::Sdg.index_from_code(@solution.problem.challenge.sdg_code.to_sym)).to_s.rjust(2, "0")
      end

      def challenge_scope
        @challenge_scope ||= current_organization.scopes.find_by(id: @solution.problem.challenge.decidim_scope_id)
      end

      def sectorial_scope
        @sectorial_scope ||= current_organization.scopes.find_by(id: @solution.problem.decidim_sectorial_scope_id)
      end

      def technological_scope
        @technological_scope ||= current_organization.scopes.find_by(id: @solution.problem.decidim_technological_scope_id)
      end

      def search_klass
        Decidim::Solutions::SolutionSearch
      end
    end
  end
end
