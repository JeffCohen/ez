module ActionController
  class Base

    helper_method :current_user
    helper_method :logged_in?

    def logged_in?
      session[:user_id].present?
    end

    def user_login(user)
      @current_user = user
      session[:user_id] = user ? user.id : nil
      user
    end

    def user_logout
      user_login nil
    end

    def current_user(klass = User)
      @current_user ||= klass.send(:find_by, id: session[:user_id])
    end

  end
end
