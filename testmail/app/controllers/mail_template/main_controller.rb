class MailTemplate::MainController < ApplicationController
  before_action :set_js_css_path, only: [:index]

  def index
    @template_datas = MailTemplate.enable.company_filter.order("updated_at DESC").page(params[:page])

    #error msg
    gon.error = Rails.application.config.error
  end

  def create
    tra_type = params["tra_type"]

    @template_datas = MailTemplate.new
    @template_datas.subject = params["title"]
    @template_datas.message = params["message"]

    @template_datas.link_flag = tra_type[:link]
    @template_datas.attach_flag = tra_type[:file]
    file_name = params["filename"]
    if tra_type[:file] == "1"
      @template_datas.attached_type_id = params["js-at-type"]

      if file_name.present?
        ext = ""
        if @template_datas.attached_type_id == AttachedTypes::DOCX
          ext = ".docx"
        elsif @template_datas.attached_type_id == AttachedTypes::XLSX
          ext = ".xlsx"
        else
          ext = ".zip"
        end
        if File.extname(file_name) != ext
          file_name = File.basename(file_name, '.*') + ext
        end
      end
    else
      @template_datas.attached_type_id = 1
    end

    @template_datas.file_name = file_name

    # render :index
    if @template_datas.save()
      redirect_to mail_template_index_url, notice: "登録しました"
    else
      logger.error @template_datas.errors.messages
      redirect_to :index
    end
  end

  def destroy
    MailTemplate.update(params[:id], {del_flag: 1})
    redirect_to mail_template_index_url, notice: "削除しました"
  end

  def get_data
    data = MailTemplate.select("subject, message, link_flag, file_name, attach_flag, attached_type_id").where("id = ?", params[:id])
    render json: data
  end

  def update

    tra_type = params["update_tra_type"]
    file_name = params["filename"]
    at_type = params["js-update-at-type"].to_i

    # 添付型以外は添付ファイルの種類は「添付なし」
    if tra_type[:file] != "1"
      at_type = AttachedTypes::NONE
    else
      if file_name.present?
        ext = ""
        if at_type == AttachedTypes::DOCX
          ext = ".docx"
        elsif at_type == AttachedTypes::XLSX
          ext = ".xlsx"
        else
          ext = ".zip"
        end
        if File.extname(file_name) != ext
          file_name = File.basename(file_name, '.*') + ext
        end
      end
    end

    result_flag = MailTemplate.update(params[:id], {subject: params["title"], message: params["message"],
      file_name: file_name, link_flag: tra_type[:link], attach_flag: tra_type[:file], attached_type_id: at_type})

    if result_flag
      redirect_to mail_template_index_url, notice: "更新しました"
    else
      logger.error ""
      redirect_to :index
    end
  end

  def get_filter_data
    word = params[:search_word]

    data = []
    MailTemplate.enable.company_filter.order("updated_at DESC").each do |mail_template|

      if mail_template.subject.to_s.include?(word)
        write_data mail_template, data
      end

    end
    render :json => {:status => 200, :data => data}, :status => 200
  end

  private
    def write_data mail_template, data
      no = data.size + 1
      data << {
          :id => no,
          :subject => mail_template.subject,
          :link_flag => mail_template.link_flag,
          :attach_flag => mail_template.attach_flag,
          :updated_at => mail_template.updated_at.strftime("%Y/%m/%d %H:%M:%S")
        }
    end

    def set_js_css_path
      @js_css_root = controller_path
      @attached_types = AttachedTypes.enable.where("id > 1").pluck(:name_ja, :id)
    end
end
