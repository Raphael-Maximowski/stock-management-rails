class UserRepository 

    def initialize(model = User)
        @model = model
    end

    def find(id)
        @model.find_by(id: id)
    end

    def list
        @model.all
    end

    def update(user, params)
        user.update(params)
        user
    end
    
    def create(params)
        params[:email] = params[:email].downcase
        @model.create(params) 
    end

    def email_exists?(email)
        @model.where(email: email.downcase).exists?
    end

    def email_exists_excluding_id?(email, user_id)
        @model.where(email: email.downcase)
        .where.not(id: user_id)
        .exists?
    end
end