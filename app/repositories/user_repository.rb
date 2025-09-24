class UserRepository 

    def initialize(model = User)
        @model = model
    end

    def user_exists_based_in_role?(user_id, role)
        @model.where(id: user_id, role: role, status: 'active').exists?
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

    def manager_exists?(id, role)
        @model.where(id: id, role: role, status: 'active').exists?
    end

    def user_exists?(id)
        @model.where(id: id).exists?
    end
    
    def client_exists?(id, role)
        @model.where(id: id, role: role, status: 'active').exists?
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