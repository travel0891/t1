<%@ WebHandler Language="C#" Class="Upload" %>

using System;
using System.Collections;
using System.Web;
using System.IO;
using System.Globalization;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using imgModeler;
using imgCtrler;
using LitJson;
using System.Configuration;

public class Upload : IHttpHandler
{
    private HttpContext context;
    private static readonly Int32 imgCount = Int32.Parse(ConfigurationManager.AppSettings["imgCount"]);

    public void ProcessRequest(HttpContext context)
    {
        String savePath = "../", saveUrl = "../";

        Hashtable extTable = new Hashtable();
        extTable.Add("imageList", "gif,jpg,jpeg,png,bmp");

        Int32 maxSize = 2560000;
        this.context = context;

        HttpPostedFile imgFile = context.Request.Files["imgFile"];
        if (imgFile == null)
        {
            showError("请选择文件。");
        }

        String dirPath = context.Server.MapPath(savePath);
        if (!Directory.Exists(dirPath))
        {
            showError("上传目录不存在。");
        }

        String dirName = context.Request.QueryString["dir"];
        String fileName = imgFile.FileName;
        String fileExt = Path.GetExtension(fileName).ToLower();

        if (imgFile.InputStream == null || imgFile.InputStream.Length > maxSize)
        {
            showError("上传文件大小超过限制。");
        }

        if (String.IsNullOrEmpty(fileExt) || Array.IndexOf(((String)extTable[dirName]).Split(','), fileExt.Substring(1).ToLower()) == -1)
        {
            showError("上传文件扩展名是不允许的扩展名。\n只允许" + ((String)extTable[dirName]) + "格式。");
        }

        dirPath += dirName + "/";
        saveUrl += dirName + "/";
        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }
        String ymd = DateTime.Now.ToString("yyyy/MM/dd", DateTimeFormatInfo.InvariantInfo);
        dirPath += ymd + "/";
        saveUrl += ymd + "/";
        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }
        String newFileName = Guid.NewGuid().ToString();
        String filePath = dirPath + newFileName + fileExt;
        Image sourceImage = null;

        imgFile.SaveAs(filePath);
        sourceImage = Image.FromFile(filePath);
        insertModel(imgFile, sourceImage, newFileName, fileExt, 0);

        Int32 f = 1;

        for (Int32 i = 1; i <= imgCount; i++)
        {
            f = i * 100;
            UpLoadImage(imgFile, filePath, f, false, f, f);
            sourceImage = Image.FromFile(filePath.Replace(fileExt, f.ToString()) + fileExt);
            insertModel(imgFile, sourceImage, newFileName + f.ToString(), fileExt, f);
        }

        String fileUrl = saveUrl + newFileName + "100" + fileExt;

        Hashtable hash = new Hashtable();
        hash["error"] = 0;
        hash["url"] = fileUrl;
        context.Response.AddHeader("Content-Type", "text/html; charset=utf-8");
        context.Response.Write(JsonMapper.ToJson(hash));
        context.Response.End();
    }

    private void showError(string message)
    {
        Hashtable hash = new Hashtable();
        hash["error"] = 1;
        hash["message"] = message;
        context.Response.AddHeader("Content-Type", "text/html; charset=utf-8");
        context.Response.Write(JsonMapper.ToJson(hash));
        context.Response.End();
    }

    private void insertModel(HttpPostedFile imgFile, Image sourceImage, String newFileName, String fileExt, Int32 formatType)
    {
        String GroupCharId = Guid.NewGuid().ToString("N");
        qzsImgModel qi = new qzsImgModel()
        {
            qzsCharId = Guid.NewGuid().ToString("N"),
            qzsUrl = DateTime.Now.ToString("/yyyy/MM/dd/", DateTimeFormatInfo.InvariantInfo) + newFileName + fileExt,
            qzsPixel4x = sourceImage.Width,
            qzsPixel4y = sourceImage.Height,
            qzsSize = Convert.ToInt32(imgFile.InputStream.Length),
            qzsType = fileExt,
            qzsGroup = GroupCharId,
            qzsSortTime = DateTime.Now.ToShortDateString(),
            qzsUpdateTime = DateTime.Now,
            qzsBoolDelete = 0
        };
        qi.qzsFormat = formatType;

        new qzsImgCtrl().insertData(qi);
    }

    public Boolean IsReusable
    {
        get
        {
            return true;
        }
    }

    private String UpLoadImage(HttpPostedFile myFile, String sSavePath, Int32 sThumbExtension, Boolean isReal, Int32 intThumbWidth, Int32 intThumbHeight)
    {
        Int32 nFileLen = myFile.ContentLength;
        String sThumbFile = String.Empty, sFilename = String.Empty, extendName = Path.GetExtension(myFile.FileName).ToLower();

        if (isReal)
        {
            Byte[] myData = new Byte[nFileLen];
            myFile.InputStream.Read(myData, 0, nFileLen);
            FileStream newFile = new FileStream(sSavePath, FileMode.Create, FileAccess.Write);
            newFile.Write(myData, 0, myData.Length);
            newFile.Close();
        }

        using (Image sourceImage = Image.FromFile(sSavePath + sFilename))
        {
            Int32 width = sourceImage.Width, height = sourceImage.Height;
            Int32 smallWidth = 0, smallHeight = 0;

            //if (((decimal)width) / height <= ((decimal)intThumbWidth) / intThumbHeight)
            //{
            //    smallWidth = intThumbWidth;
            //    smallHeight = intThumbWidth * height / width;
            //}
            //else
            //{
            //    smallWidth = intThumbHeight * width / height;
            //    smallHeight = intThumbHeight;
            //}

            smallWidth = intThumbWidth;
            smallHeight = intThumbWidth * height / width;

            intThumbWidth = smallWidth;
            intThumbHeight = smallHeight;

            sThumbFile = sSavePath;
            String smallImagePath = sSavePath.Replace(extendName, sThumbExtension.ToString()) + extendName;

            using (Bitmap bitmap = new Bitmap(intThumbWidth, intThumbHeight))
            {
                using (Graphics graphic = Graphics.FromImage(bitmap))
                {
                    graphic.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    graphic.SmoothingMode = SmoothingMode.HighQuality;
                    graphic.Clear(Color.White);
                    graphic.DrawImage(sourceImage
                        , new Rectangle(-1, -1, intThumbWidth + 1, intThumbHeight + 1)
                        , new Rectangle(0, 0, sourceImage.Width, sourceImage.Height)
                        , GraphicsUnit.Pixel);
                    graphic.Dispose();
                    bitmap.Save(smallImagePath, ImageFormat.Jpeg);
                }
            }

            #region
            //using (Image bitmap = new Bitmap(smallWidth, smallHeight))
            //{
            //    using (Graphics g = Graphics.FromImage(bitmap))
            //    {
            //        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            //        g.SmoothingMode = SmoothingMode.None;
            //        g.Clear(Color.Black);
            //        g.DrawImage(
            //        sourceImage,
            //        new Rectangle(0, 0, smallWidth, smallHeight),
            //        new Rectangle(0, 0, width, height),
            //        GraphicsUnit.Pixel);
            //    }
            //    using (Image bitmap1 = new Bitmap(intThumbWidth, intThumbHeight))
            //    {
            //        using (Graphics g = Graphics.FromImage(bitmap1))
            //        {
            //            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            //            g.SmoothingMode = SmoothingMode.None;
            //            g.Clear(Color.Black);
            //            int lwidth = (smallWidth - intThumbWidth) / 2;
            //            int bheight = (smallHeight - intThumbHeight) / 2;
            //            g.DrawImage(
            //                bitmap
            //                , new Rectangle(0, 0, intThumbWidth, intThumbHeight)
            //                , lwidth, bheight
            //                , intThumbWidth
            //                , intThumbHeight
            //                , GraphicsUnit.Pixel);
            //            g.Dispose();
            //            bitmap1.Save(smallImagePath, ImageFormat.Jpeg);
            //        }
            //    }
            //}
            #endregion
        }
        return sThumbFile;
    }
}