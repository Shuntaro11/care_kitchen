# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @user = User.new
  end

  # POST /resource
  def create
    @user = User.new(sign_up_params)
    unless @user.valid?
      flash.now[:alert] = @user.errors.full_messages
      render :new and return
    end
    session["create_acount"] = { user: @user.attributes}
    session["create_acount"][:user]["password"] = params[:user][:password] 
    @person = @user.people.build
    render :new_first_person
  end

  def create_first_person
    @user = User.new(session["create_acount"]["user"])
    @person = Person.new(person_params)
    @personal_information = PersonalInformation.new(@person.personal_informations[0].attributes)
    weight = @personal_information[:weight]
    height = @personal_information[:height]
    bmi = (weight/height/height).round(1)
    @personal_information[:bmi] = bmi
    @user.people.build(@person.attributes)
    @user.people[0].personal_informations.build(@personal_information.attributes)
    unless @person.valid? && @personal_information.valid?
      flash[:alert] = "入力が誤っています"
      render :new_first_person and return
    end
    @user.save
    sign_in(:user, @user)
    redirect_to root_path
  end



  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

  def person_params
    params.require(:person).permit(:name,:birthday,:gender,:image,personal_informations_attributes: [:height,:weight,:date,:id])
  end
  # personal_informations_attributes: [:height,:weight,:id]

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
