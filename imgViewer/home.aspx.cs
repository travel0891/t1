namespace imgViewer
{
    using imgCtrler;
    using imgModeler;
    using System;
    using System.Configuration;
    using System.Text;

    public partial class home : System.Web.UI.Page
    {
        private static readonly Int32 imgCount = int.Parse(ConfigurationManager.AppSettings["imgCount"]);
        private static readonly String otherUrl = ConfigurationManager.AppSettings["otherUrl"];

        protected void Page_Load(object sender, EventArgs e)
        {
            StringBuilder sbHTML = new StringBuilder();

            foreach (qzsImgModel itme in (new qzsImgCtrl().selectData100()))
            {
                Int32 f = 0;
                sbHTML.Append("<div class=\"imgDiv\">");

                sbHTML.Append("<div>");
                sbHTML.Append("<img title=\"" + itme.qzsUpdateTime + "\" src=\"/imageList" + itme.qzsUrl + "\" />");
                sbHTML.Append("</div>");

                sbHTML.Append("<div>");
                sbHTML.Append("<select onchange=\"javascript:getUrl(this.value);\">");
                sbHTML.Append("<option title=\"" + itme.qzsUpdateTime + "\" value=\"\">" + itme.qzsSortTime + "</option>");
                for (Int32 i = 0; i <= imgCount; i++)
                {
                    if (i == 0)
                    {
                        sbHTML.Append("<option value=\"" + otherUrl + itme.qzsUrl.Replace(itme.qzsFormat + itme.qzsType, itme.qzsType) + "\">master</option>");
                    }
                    else
                    {
                        f = i * 100;
                        sbHTML.Append("<option value=\"" + otherUrl + itme.qzsUrl.Replace(itme.qzsFormat + itme.qzsType, f.ToString() + itme.qzsType) + "\">" + f + "*" + f + "</option>");
                    }
                }
                sbHTML.Append("</select>");
                sbHTML.Append("</div>");

                sbHTML.Append("</div>");
            }

            urlList.InnerHtml = sbHTML.ToString();
        }
    }
}