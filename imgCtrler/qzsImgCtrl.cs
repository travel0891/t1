namespace imgCtrler
{
    using imgModeler;
    using MongoDB;
    using System;
    using System.Collections.Generic;
    using System.Linq;

    public class qzsImgCtrl
    {
        private static readonly String connectionString = "Server=127.0.0.1";
        private static readonly String databaseString = "travelOne";

        public List<qzsImgModel> selectData()
        {
            List<qzsImgModel> im = new List<qzsImgModel>();
            using (Mongo mongo = new Mongo(connectionString))
            {
                mongo.Connect();
                var db = mongo.GetDatabase(databaseString);
                var collecton = db.GetCollection<qzsImgModel>().Find(x => x.qzsBoolDelete == 0).Sort("{qzsUpdateTime:-1}").Documents.ToList();
                im.AddRange(collecton);
            }
            return im;
        }

        public void insertData(qzsImgModel model)
        {
            using (Mongo mongo = new Mongo(connectionString))
            {
                mongo.Connect();
                var db = mongo.GetDatabase(databaseString);
                var collection = db.GetCollection<qzsImgModel>();
                collection.Insert(model);
            }
        }

        public List<qzsImgModel> selectData100()
        {
            List<qzsImgModel> im = new List<qzsImgModel>();
            using (Mongo mongo = new Mongo(connectionString))
            {
                mongo.Connect();
                var db = mongo.GetDatabase(databaseString);
                var collecton = db.GetCollection<qzsImgModel>().Find(x => x.qzsFormat == 100).Sort("{qzsUpdateTime:-1}").Documents.ToList();
                im.AddRange(collecton);
            }
            return im;
        }
    }
}