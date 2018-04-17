# frozen_string_literal: true

module API
  module V1
    class LesseesController < API::ApplicationController
      before_action :set_lessee, only: %i[show update destroy]

      def find
        @lessee = Lessee.find_by(identifier: params[:identifier])
        return head :not_found if @lessee.blank?
        render :show
      end

      def index
        @lessees = []
        if params[:product_id].present?
          set_product!
          @lessees = @product.lessees
        else
          @lessees = Lessee.all
        end
      end

      def show
        return head :not_found if @lessee.blank?
        if params[:product_id].present? # rubocop:disable Style/GuardClause
          product = Product.find_by(id: params[:product_id])
          return head :not_found if product.blank?
          return head :not_found unless product.lessees.include?(@lessee)
        end
      end

      def create
        if params[:product_id].present?
          create_product_lessee
        else
          create_lessee
        end
      end

      def update
        if params[:product_id].present?
          update_product_lessee
        else
          update_lessee
        end
      end

      def destroy
        if params[:product_id].present?
          set_product!
          @product.lessees.delete(@lessee) if @product.lessees.include?(@lessee)
        else
          return head :ok if @lessee.blank?
          return head :accepted unless @lessee.products.empty?
          @lessee.delete
        end
        head :ok
      end

      private

        def create_lessee
          status = :ok
          @lessee = Lessee.find_by(identifier: lessee_params[:identifier])
          if @lessee.blank?
            @lessee = Lessee.new(lessee_params)
            return render json: @lessee.errors, status: :unprocessable_entity unless @lessee.save
            status = :created
          end
          render :show, status: status, location: @lessee
        end

        def create_product_lessee
          status = :ok
          set_product!
          @lessee = Lessee.find_by(identifier: lessee_params[:identifier])
          if @lessee.blank?
            @lessee = Lessee.new(lessee_params)
            return render json: @lessee.errors, status: :unprocessable_entity unless @lessee.save
            status = :created
          end
          unless @product.lessees.include?(@lessee)
            @product.lessees << @lessee
            @product.save
          end
          render :show, status: status, location: @lessee
        end

        def update_lessee
          status = :ok
          if @lessee.blank?
            @lessee = Lessee.new(identifier: params[:identifier])
            return render json: @lessee.errors, status: :unprocessable_entity unless @lessee.save
            status = :created
          end
          render :show, status: status, location: @lessee
        end

        def update_product_lessee
          set_product!
          set_lessee!
          unless @product.lessees.include?(@lessee)
            @product.lessees << @lessee
            @product.save
          end
          render :show, status: :ok, location: @lessee
        end

        def set_product!
          @product = Product.find_by!(id: params[:product_id])
        end

        def set_lessee!
          @lessee = Lessee.find_by!(id: params[:id])
        end

        # Use callbacks to share common setup or constraints between actions.
        def set_lessee
          @lessee = Lessee.find_by(id: params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def lessee_params
          params.require(:lessee).permit(:identifier)
        end
    end
  end
end