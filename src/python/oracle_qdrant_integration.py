import cx_Oracle
from qdrant_client import QdrantClient
from qdrant_client.http import models
import numpy as np
from sentence_transformers import SentenceTransformer
import pandas as pd

class OracleQdrantIntegration:
    def __init__(self):
        # Initialize Oracle connection
        self.oracle_conn = cx_Oracle.connect(
            'app_user/app_password@sql_stuff-oracle-1:1521/FREEPDB1'
        )

        # Initialize Qdrant client
        self.qdrant_client = QdrantClient("localhost", port=6333)

        # Initialize the sentence transformer model
        self.model = SentenceTransformer('all-MiniLM-L6-v2')

        # Collection name in Qdrant
        self.collection_name = "oracle_embeddings"

    def setup_qdrant_collection(self):
        """Create or recreate the Qdrant collection"""
        # First, try to delete if exists
        try:
            self.qdrant_client.delete_collection(self.collection_name)
        except:
            pass

        # Create new collection
        self.qdrant_client.create_collection(
            collection_name=self.collection_name,
            vectors_config=models.VectorParams(
                size=384,  # Dimension of all-MiniLM-L6-v2 embeddings
                distance=models.Distance.COSINE
            )
        )

    def fetch_oracle_data(self, query):
        """Fetch data from Oracle DB"""
        cursor = self.oracle_conn.cursor()
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        data = cursor.fetchall()
        cursor.close()
        return pd.DataFrame(data, columns=columns)

    def create_embeddings(self, texts):
        """Create embeddings from text using sentence-transformers"""
        return self.model.encode(texts)

    def store_embeddings(self, embeddings, metadata_list):
        """Store embeddings and metadata in Qdrant"""
        self.qdrant_client.upload_points(
            collection_name=self.collection_name,
            points=models.Batch(
                ids=list(range(len(embeddings))),
                vectors=embeddings.tolist(),
                payloads=metadata_list
            )
        )

    def search_similar(self, query_text, limit=5):
        """Search for similar items in Qdrant"""
        query_vector = self.model.encode(query_text)

        search_result = self.qdrant_client.search(
            collection_name=self.collection_name,
            query_vector=query_vector,
            limit=limit
        )

        return search_result

    def process_employee_data(self):
        """Process employee data as an example"""
        # Fetch employee data
        query = """
        SELECT
            e.employee_id,
            e.first_name,
            e.last_name,
            e.department,
            e.position,
            ep.comments as performance_comments,
            ep.goals_achieved,
            ep.improvement_areas
        FROM
            employees e
            LEFT JOIN employee_performance ep ON e.employee_id = ep.employee_id
        """

        df = self.fetch_oracle_data(query)

        # Create text representations for embedding
        texts = []
        metadata_list = []

        for _, row in df.iterrows():
            # Create a rich text representation
            text = f"Employee {row['FIRST_NAME']} {row['LAST_NAME']} works in {row['DEPARTMENT']} "
            text += f"as {row['POSITION']}. "
            if row['PERFORMANCE_COMMENTS']:
                text += f"Performance: {row['PERFORMANCE_COMMENTS']}. "
            if row['GOALS_ACHIEVED']:
                text += f"Goals: {row['GOALS_ACHIEVED']}. "
            if row['IMPROVEMENT_AREAS']:
                text += f"Areas for improvement: {row['IMPROVEMENT_AREAS']}."

            texts.append(text)

            # Create metadata
            metadata = {
                'employee_id': row['EMPLOYEE_ID'],
                'name': f"{row['FIRST_NAME']} {row['LAST_NAME']}",
                'department': row['DEPARTMENT'],
                'position': row['POSITION']
            }
            metadata_list.append(metadata)

        # Create embeddings
        embeddings = self.create_embeddings(texts)

        # Store in Qdrant
        self.store_embeddings(embeddings, metadata_list)

        return len(texts)

def main():
    # Initialize the integration
    integration = OracleQdrantIntegration()

    # Setup Qdrant collection
    print("Setting up Qdrant collection...")
    integration.setup_qdrant_collection()

    # Process employee data
    print("Processing employee data...")
    count = integration.process_employee_data()
    print(f"Processed {count} employee records")

    # Example search
    print("\nPerforming example searches...")

    # Search for IT professionals
    results = integration.search_similar("IT department professionals with good performance")
    print("\nIT Professionals:")
    for result in results:
        print(f"Match score: {result.score}")
        print(f"Employee: {result.payload['name']}")
        print(f"Department: {result.payload['department']}")
        print(f"Position: {result.payload['position']}")
        print("---")

    # Search for management positions
    results = integration.search_similar("management positions with leadership skills")
    print("\nManagement Positions:")
    for result in results:
        print(f"Match score: {result.score}")
        print(f"Employee: {result.payload['name']}")
        print(f"Department: {result.payload['department']}")
        print(f"Position: {result.payload['position']}")
        print("---")

if __name__ == "__main__":
    main()
