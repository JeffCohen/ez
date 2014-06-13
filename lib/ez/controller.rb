module ActionController
  class Base

    helper_method :current_user
    helper_method :user_signed_in?

    def user_signed_in?
      session[:user_id].present?
    end

    def sign_in_as(user)
      @current_user = user
      session[:user_id] = user.try(:id)
      user
    end

    def sign_out
      sign_in_as nil
    end

    def current_user(klass = User)
      @current_user ||= klass.send(:find_by, id: session[:user_id])
    end

  end
end
