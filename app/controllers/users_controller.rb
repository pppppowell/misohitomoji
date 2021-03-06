class UsersController < ApplicationController
  before_action :authenticate_user,{only: [:index, :show, :edit, :update]}
  before_action :forbid_login_user,{only: [:login_form, :login, :create, :new]}
  before_action :ensure_correct_user,{only: [:edit, :update]}

  def new
    @user=User.new
  end
  
  def index
    @users=User.all
  end
  
  def show
    @user=User.find_by(id: params[:id])
  end

  def edit
    @user=User.find_by(id: params[:id])
  end

  def create
    @user=User.new(
      name: params[:name],
      email: params[:email],
      image_name: "default_user.jpg",
      password: params[:password]
   )
    if @user.save
      session[:user_id]=@user.id
      flash[:notice]="ユーザー登録が完了しました"
      redirect_to("/users/#{@user.id}")
    else
      render("users/new")
    end
  end

  def update
    @user=User.find_by(id: params[:id])
    if @user.id==6
      @error_message="テストユーザーの情報は変更できません"
      render("users/edit")
    else
      @user.email=params[:email]
      @user.name=params[:name]

    if params[:image]
      @user.image_name="#{@user.id}.jpg"
      image=params[:image]
      File.binwrite("public/user_images/#{@user.image_name}",image.read)
    end

    if @user.save
      flash[:notice]="ユーザー情報を編集しました"
      redirect_to("/users/#{@user.id}")
    else
      render("users/edit")
    end
  end
  end

  def login_form
  end

  def login
    @user=User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id]=@user.id
      flash[:notice]="ログインしました"
      redirect_to("/posts/index")
    else
      @error_message="メールアドレスまたはパスワードが間違っています"
      @email=params[:email]
      @password=params[:password]
      render("users/login_form")
    end
  end

  def logout
    session[:user_id]=nil
    flash[:notice]="ログアウトしました"
    redirect_to("/login")
  end
  
  def ensure_correct_user
    if @current_user.id != params[:id].to_i
      flash[:notice]="権限がありません"
      redirect_to("/posts/index")
    end
  end

  def likes
    @user=User.find_by(id: params[:id])
    @likes=Like.where(user_id: @user.id)
  end
end
